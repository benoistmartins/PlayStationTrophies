//
//  PSNAPIService.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

final class PSNAPIService {
    let authService: PSNAuthService
    private let baseURL = "https://m.np.playstation.com/api/trophy/v1"
    private let profileBaseURL = "https://m.np.playstation.com/api/userProfile/v1/internal/users"

    init(authService: PSNAuthService) {
        self.authService = authService
    }

    // MARK: - Profile

    func fetchProfile(accountId: String) async throws -> PSNProfile {
        let token = try await authService.validAccessToken()
        let url = URL(string: "\(profileBaseURL)/\(accountId)/profiles")!
        let data = try await get(url: url, token: token)
        return try decode(PSNProfile.self, from: data)
    }

    // MARK: - Search account ID by PSN ID

    func fetchAccountId(for psnId: String) async throws -> String {
        let token = try await authService.validAccessToken()
        let url = URL(string: "https://m.np.playstation.com/api/search/v1/universalSearch")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("4.0", forHTTPHeaderField: "X-Psn-Schema-Version")
        request.setValue("PlayStation/22.5.0 CFNetwork/1399 Darwin/22.1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "searchTerm": psnId,
            "domainRequests": [["domain": "SocialAllAccounts"]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PSNAPIError.invalidResponse
        }

        if httpResponse.statusCode == 403 { throw PSNAPIError.privateProfile(psnId) }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ PSNAPIService | HTTP \(httpResponse.statusCode) — universalSearch")
            print("❌ PSNAPIService | Body: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw PSNAPIError.httpError(httpResponse.statusCode)
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let domainResponses = json?["domainResponses"] as? [[String: Any]]
        let results = domainResponses?.first?["results"] as? [[String: Any]]
        let socialMetadata = results?.first?["socialMetadata"] as? [String: Any]

        guard let accountId = socialMetadata?["accountId"] as? String else {
            throw PSNAPIError.userNotFound(psnId)
        }
        return accountId
    }

    // MARK: - Titles

    func fetchAllTitles() async throws -> [PSNTitle] {
        let token = try await authService.validAccessToken()
        var allTitles: [PSNTitle] = []
        var offset = 0
        let limit = 100

        repeat {
            var components = URLComponents(string: "\(baseURL)/users/me/trophyTitles")!
            components.queryItems = [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
            let data = try await get(url: components.url!, token: token)
            let response = try decode(PSNTitleResponse.self, from: data)
            allTitles.append(contentsOf: response.trophyTitles)
            guard let total = response.totalItemCount, allTitles.count < total else { break }
            offset += limit
        } while true

        return allTitles
    }

    // MARK: - Trophy Groups

    func fetchTrophyGroups(npCommunicationId: String, serviceName: PSNServiceName) async throws -> [PSNTrophyGroup] {
        let token = try await authService.validAccessToken()
        var components = URLComponents(string: "\(baseURL)/npCommunicationIds/\(npCommunicationId)/trophyGroups")!
        components.queryItems = [URLQueryItem(name: "npServiceName", value: serviceName.rawValue)]
        let data = try await get(url: components.url!, token: token)
        let response = try decode(PSNTrophyGroupsResponse.self, from: data)
        return response.trophyGroups
    }

    // MARK: - Trophies

    func fetchTrophyDefinitions(npCommunicationId: String, serviceName: PSNServiceName) async throws -> [PSNTrophy] {
        let token = try await authService.validAccessToken()
        var components = URLComponents(string: "\(baseURL)/npCommunicationIds/\(npCommunicationId)/trophyGroups/all/trophies")!
        components.queryItems = [URLQueryItem(name: "npServiceName", value: serviceName.rawValue)]
        let data = try await get(url: components.url!, token: token)
        let response = try decode(PSNTrophiesResponse.self, from: data)
        return response.trophies
    }

    func fetchEarnedTrophies(npCommunicationId: String, serviceName: PSNServiceName) async throws -> [PSNTrophy] {
        let token = try await authService.validAccessToken()
        var components = URLComponents(string: "\(baseURL)/users/me/npCommunicationIds/\(npCommunicationId)/trophyGroups/all/trophies")!
        components.queryItems = [URLQueryItem(name: "npServiceName", value: serviceName.rawValue)]
        let data = try await get(url: components.url!, token: token)
        let response = try decode(PSNTrophiesResponse.self, from: data)
        return response.trophies
    }

    func fetchEarnedTrophies(for accountId: String, npCommunicationId: String, serviceName: PSNServiceName, psnId: String) async throws -> [PSNTrophy] {
        let token = try await authService.validAccessToken()
        var components = URLComponents(string: "\(baseURL)/users/\(accountId)/npCommunicationIds/\(npCommunicationId)/trophyGroups/all/trophies")!
        components.queryItems = [URLQueryItem(name: "npServiceName", value: serviceName.rawValue)]

        var request = URLRequest(url: components.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("4.0", forHTTPHeaderField: "X-Psn-Schema-Version")
        request.setValue("PlayStation/22.5.0 CFNetwork/1399 Darwin/22.1.0", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PSNAPIError.invalidResponse
        }

        if httpResponse.statusCode == 403 { throw PSNAPIError.privateProfile(psnId) }
        if httpResponse.statusCode == 404 { throw PSNAPIError.gameNotFound(psnId) }
        if httpResponse.statusCode == 429 { throw PSNAPIError.rateLimited }

        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ PSNAPIService | HTTP \(httpResponse.statusCode) — \(components.url!.absoluteString)")
            print("❌ PSNAPIService | Body: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw PSNAPIError.httpError(httpResponse.statusCode)
        }

        return try decode(PSNTrophiesResponse.self, from: data).trophies
    }

    // MARK: - Private

    private func get(url: URL, token: String) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("4.0", forHTTPHeaderField: "X-Psn-Schema-Version")
        request.setValue("PlayStation/22.5.0 CFNetwork/1399 Darwin/22.1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PSNAPIError.invalidResponse
        }
        if httpResponse.statusCode == 429 { throw PSNAPIError.rateLimited }
        guard (200...299).contains(httpResponse.statusCode) else {
            print("❌ PSNAPIService | HTTP \(httpResponse.statusCode) — \(url.absoluteString)")
            print("❌ PSNAPIService | Body: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw PSNAPIError.httpError(httpResponse.statusCode)
        }
        return data
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("❌ PSNAPIService | Decoding error for \(T.self): \(error)")
            throw PSNAPIError.decodingFailed
        }
    }
}