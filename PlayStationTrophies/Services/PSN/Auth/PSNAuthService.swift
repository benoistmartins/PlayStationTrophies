//
//  PSNAuthService.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation
import Combine

final class PSNAuthService: ObservableObject {
    @Published var credentials: PSNCredentials? = nil
    @Published var isAuthenticated: Bool = false
    @Published var accountId: String? = nil

    private let credentialsKey = "psn_credentials"
    private let clientID = "09515159-7237-4370-9b40-3806e67c0891"
    private let scope = "psn:mobile.v2.core psn:clientapp"
    private let redirectURI = "com.scee.psxandroid.scecompcall://redirect"

    init() {
        loadCredentials()
    }

    // MARK: - Public

    func validAccessToken() async throws -> String {
        guard let creds = credentials else {
            throw PSNAuthError.notAuthenticated
        }
        if creds.isAccessTokenValid {
            return creds.accessToken
        }
        if creds.isRefreshTokenValid {
            return try await refreshAccessToken(using: creds.refreshToken)
        }
        throw PSNAuthError.notAuthenticated
    }

    func exchangeNpssoForTokens(npsso: String) async throws {
        do {
            let (accessCode, cid) = try await getAccessCode(npsso: npsso)
            let tokens = try await exchangeAccessCodeForTokens(accessCode: accessCode, cid: cid)
            let creds = PSNCredentials(
                accessToken: tokens.accessToken,
                refreshToken: tokens.refreshToken,
                accessTokenExpiry: Date().addingTimeInterval(TimeInterval(tokens.expiresIn)),
                refreshTokenExpiry: Date().addingTimeInterval(TimeInterval(tokens.refreshTokenExpiresIn))
            )
            await MainActor.run {
                credentials = creds
                accountId = PSNJWTDecoder.extractAccountId(from: tokens.accessToken)
                isAuthenticated = true
            }
            saveCredentials(creds)
        } catch {
            throw error
        }
    }

    func logout() {
        credentials = nil
        isAuthenticated = false
        accountId = nil
        UserDefaults.standard.removeObject(forKey: credentialsKey)
    }

    // MARK: - Private

    private func getAccessCode(npsso: String) async throws -> (code: String, cid: String) {
        var components = URLComponents(string: "https://ca.account.sony.com/api/authz/v3/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scope)
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("npsso=\(npsso)", forHTTPHeaderField: "Cookie")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let config = URLSessionConfiguration.default
        config.httpShouldSetCookies = false
        config.httpCookieAcceptPolicy = .never

        let delegate = RedirectInterceptor()
        let session = URLSession(configuration: config, delegate: delegate, delegateQueue: nil)

        do {
            let (_, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse,
               let location = httpResponse.value(forHTTPHeaderField: "Location") {
                if let url = URL(string: location),
                   let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value,
                   let cid = urlComponents.queryItems?.first(where: { $0.name == "cid" })?.value {
                    return (code: code, cid: cid)
                }
            }
        } catch {
            if let urlError = error as? URLError,
               let failingURL = urlError.failingURL {
                if let urlComponents = URLComponents(url: failingURL, resolvingAgainstBaseURL: false),
                   let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value,
                   let cid = urlComponents.queryItems?.first(where: { $0.name == "cid" })?.value {
                    return (code: code, cid: cid)
                }
            }
        }

        throw PSNAuthError.accessCodeFailed
    }

    private func exchangeAccessCodeForTokens(accessCode: String, cid: String) async throws -> PSNTokenResponse {
        let url = URL(string: "https://ca.account.sony.com/api/authz/v3/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic MDk1MTUxNTktNzIzNy00MzcwLTliNDAtMzgwNmU2N2MwODkxOnVjUGprYTV0bnRCMktxc1A=", forHTTPHeaderField: "Authorization")
        request.setValue("com.sony.snei.np.android.sso.share.oauth.versa.USER_AGENT", forHTTPHeaderField: "User-Agent")
        request.setValue(cid, forHTTPHeaderField: "X-Psn-Correlation-Id")

        let body: [String: String] = [
            "cid": cid,
            "code": accessCode,
            "grant_type": "authorization_code",
            "redirect_uri": redirectURI,
            "scope": scope,
            "token_format": "jwt"
        ]
        request.httpBody = encodeBody(body)

        let (data, _) = try await URLSession.shared.data(for: request)

        return try JSONDecoder().decode(PSNTokenResponse.self, from: data)
    }

    @discardableResult
    private func refreshAccessToken(using refreshToken: String) async throws -> String {
        let url = URL(string: "https://ca.account.sony.com/api/authz/v3/oauth/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic MDk1MTUxNTktNzIzNy00MzcwLTliNDAtMzgwNmU2N2MwODkxOnVjUGprYTV0bnRCMktxc1A=", forHTTPHeaderField: "Authorization")
        request.setValue("com.sony.snei.np.android.sso.share.oauth.versa.USER_AGENT", forHTTPHeaderField: "User-Agent")

        let body: [String: String] = [
            "refresh_token": refreshToken,
            "grant_type": "refresh_token",
            "scope": scope,
            "token_format": "jwt"
        ]
        request.httpBody = encodeBody(body)

        let (data, _) = try await URLSession.shared.data(for: request)

        let tokens = try JSONDecoder().decode(PSNTokenResponse.self, from: data)
        let updatedCreds = PSNCredentials(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken,
            accessTokenExpiry: Date().addingTimeInterval(TimeInterval(tokens.expiresIn)),
            refreshTokenExpiry: Date().addingTimeInterval(TimeInterval(tokens.refreshTokenExpiresIn))
        )
        await MainActor.run {
            credentials = updatedCreds
            accountId = PSNJWTDecoder.extractAccountId(from: tokens.accessToken)
        }
        saveCredentials(updatedCreds)
        return tokens.accessToken
    }

    private func encodeBody(_ body: [String: String]) -> Data? {
        body.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)
    }

    private func saveCredentials(_ creds: PSNCredentials) {
        if let data = try? JSONEncoder().encode(creds) {
            UserDefaults.standard.set(data, forKey: credentialsKey)
        }
    }

    private func loadCredentials() {
        guard let data = UserDefaults.standard.data(forKey: credentialsKey),
              let creds = try? JSONDecoder().decode(PSNCredentials.self, from: data) else { return }
        credentials = creds
        isAuthenticated = creds.isRefreshTokenValid
        accountId = PSNJWTDecoder.extractAccountId(from: creds.accessToken)
    }
}
