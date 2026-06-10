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
            throw PSNAPIError.httpError(httpResponse.statusCode)
        }
        return data
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw PSNAPIError.decodingFailed
        }
    }
}
