//
//  PSNCompareService.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 23/06/2026.
//

import Foundation

final class PSNCompareService {
    private let apiService: PSNAPIService

    init(apiService: PSNAPIService) {
        self.apiService = apiService
    }

    func compare(game: Game, withPSNId psnId: String) async throws -> CompareResult {
        let accountId = try await apiService.fetchAccountId(for: psnId)

        guard let communicationId = game.psnCommunicationId,
              let serviceNameString = game.psnServiceName else {
            throw PSNAPIError.invalidResponse
        }

        let serviceName = PSNServiceName(from: serviceNameString)

        async let theirTrophiesTask = apiService.fetchEarnedTrophies(
            for: accountId,
            npCommunicationId: communicationId,
            serviceName: serviceName,
            psnId: psnId
        )
        async let profileTask = try? apiService.fetchProfile(accountId: accountId)

        let theirTrophies = try await theirTrophiesTask
        let profile = await profileTask

        let theirMap = Dictionary(uniqueKeysWithValues: theirTrophies.map { ($0.trophyId, $0) })

        var result: [ComparisonGroup: [TrophyComparison]] = [
            .bothEarned: [],
            .onlyMe: [],
            .onlyThem: [],
            .neitherEarned: []
        ]

        var friendEarnedPoints = 0
        let maxPoints = game.maxPoints

        for trophy in game.trophies {
            guard let psnTrophyId = trophy.psnTrophyId else { continue }
            let theirEarned = theirMap[psnTrophyId]?.earned ?? false
            let myEarned = trophy.isUnlocked

            if theirEarned && trophy.type != .platinum {
                friendEarnedPoints += trophy.type.points
            }

            let comparison = TrophyComparison(
                trophy: trophy,
                myStatus: myEarned,
                theirStatus: theirEarned
            )

            switch (myEarned, theirEarned) {
            case (true, true):   result[.bothEarned]!.append(comparison)
            case (true, false):  result[.onlyMe]!.append(comparison)
            case (false, true):  result[.onlyThem]!.append(comparison)
            case (false, false): result[.neitherEarned]!.append(comparison)
            }
        }

        let friendCompletion: Double = {
            guard maxPoints > 0 else { return 0 }
            let raw = Double(friendEarnedPoints) / Double(maxPoints) * 100
            return raw > 0 && raw < 1 ? 1 : raw
        }()

        let friendCount = (result[.bothEarned]?.count ?? 0) + (result[.onlyThem]?.count ?? 0)
        let avatarUrl = profile?.avatarUrl.flatMap {
            URL(string: $0.replacingOccurrences(of: "http://", with: "https://"))
        }

        return CompareResult(
            comparisons: result,
            friendAvatarUrl: avatarUrl,
            friendTrophyCount: friendCount,
            friendCompletionPercentage: friendCompletion
        )
    }
}
