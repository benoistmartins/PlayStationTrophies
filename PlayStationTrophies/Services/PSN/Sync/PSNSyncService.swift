//
//  PSNSyncService.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

final class PSNSyncService {
    private let apiService: PSNAPIService
    private let store: DataStore
    private let profileStore: ProfileStore

    init(apiService: PSNAPIService, store: DataStore, profileStore: ProfileStore) {
        self.apiService = apiService
        self.store = store
        self.profileStore = profileStore
    }

    // MARK: - Sync All

    func syncAll(optimized: Bool = true) async throws -> (PSNSyncResult, [AchievementUnlock]) {
        try await syncProfile()
        return try await syncGames(optimized: optimized)
    }

    // MARK: - Profile

    func syncProfile() async throws {
        guard let accountId = apiService.authService.accountId else {
            throw PSNAuthError.notAuthenticated
        }
        let psnProfile = try await apiService.fetchProfile(accountId: accountId)
        await MainActor.run {
            profileStore.profile.username = psnProfile.onlineId
            if let avatarUrl = psnProfile.avatarUrl {
                profileStore.profile.avatarURL = URL(string: avatarUrl)
            }
            profileStore.save()
        }
    }

    // MARK: - Games

    func syncGames(optimized: Bool = true) async throws -> (PSNSyncResult, [AchievementUnlock]) {
        let titles = try await apiService.fetchAllTitles()
        let playtimes = (try? await apiService.fetchPlaytimes()) ?? []
        var result = PSNSyncResult()
        var allAchievements: [AchievementUnlock] = []

        for title in titles {
            guard title.hiddenFlag != true else {
                result.skipped += 1
                continue
            }
            do {
                let achievements = try await syncTitle(title, result: &result, force: !optimized, playtimes: playtimes)
                allAchievements.append(contentsOf: achievements)
            } catch {
                result.errors.append("\(title.trophyTitleName): \(error.localizedDescription)")
            }
        }

        await MainActor.run {
            deduplicateGames()
            store.savePublic()
        }

        return (result, allAchievements)
    }

    // MARK: - Sync single game

    func syncSingleGame(communicationId: String, serviceName: String) async throws -> [AchievementUnlock] {
        let titles = try await apiService.fetchAllTitles()
        guard let title = titles.first(where: { $0.npCommunicationId == communicationId }) else {
            throw PSNAPIError.invalidResponse
        }
        let playtimes = (try? await apiService.fetchPlaytimes()) ?? []

        let normalizedTitle = normalize(title.trophyTitleName)
        print("🔍 PSN normalized: '\(normalizedTitle)'")

        if let match = playtimes.first(where: { normalizedMatch($0.name ?? "", title.trophyTitleName) }) {
            print("✅ Matched: '\(match.name ?? "")' → '\(normalize(match.name ?? ""))'")
            print("⏱ Duration: \(match.playDuration ?? "nil")")
            print("📅 First: \(match.firstPlayedDateTime ?? "nil")")
            print("📅 Last: \(match.lastPlayedDateTime ?? "nil")")
        } else {
            print("❌ No match for: '\(title.trophyTitleName)'")
            let allCandidates = playtimes.map { "'\($0.name ?? "?")' → '\(normalize($0.name ?? ""))'" }
            print("🎮 All gamelist candidates: \(allCandidates)")
        }

        var result = PSNSyncResult()
        let achievements = try await syncTitle(title, result: &result, force: true, playtimes: playtimes)
        await MainActor.run { store.savePublic() }
        return achievements
    }

    // MARK: - Deduplication

    private func deduplicateGames() {
        var seen: Set<String> = []
        var toRemove: [UUID] = []

        for game in store.games {
            guard let id = game.psnCommunicationId else { continue }
            if seen.contains(id) {
                toRemove.append(game.id)
            } else {
                seen.insert(id)
            }
        }

        if !toRemove.isEmpty {
            store.games.removeAll { toRemove.contains($0.id) }
        }
    }

    // MARK: - Should sync

    private func shouldSync(_ title: PSNTitle, game: Game) -> Bool {
        if let psnDateString = title.lastUpdatedDateTime,
           let psnDate = ISO8601DateFormatter().date(from: psnDateString),
           psnDate > game.lastUpdate {
            return true
        }

        let psnTotal = title.definedTrophies.bronze
                     + title.definedTrophies.silver
                     + title.definedTrophies.gold
                     + title.definedTrophies.platinum
        if psnTotal != game.totalTrophies {
            return true
        }

        if let psnProgress = title.progress {
            if let localProgress = game.psnProgress {
                if psnProgress != localProgress { return true }
            } else if psnProgress > 0 {
                return true
            }
        }

        return false
    }

    // MARK: - Name normalization

    private func normalize(_ str: String) -> String {
        var result = str
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\u{00AE}", with: "")
            .replacingOccurrences(of: "\u{2122}", with: "")
            .replacingOccurrences(of: "®", with: "")
            .replacingOccurrences(of: "™", with: "")
            .replacingOccurrences(of: "©", with: "")
            .replacingOccurrences(of: " Trophy Set", with: "")
            .replacingOccurrences(of: " Trophies", with: "")
            .replacingOccurrences(of: "'", with: "'")
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: " :", with: ":")
            .replacingOccurrences(of: ":", with: "")
            .replacingOccurrences(of: "-", with: " ")
            .trimmingCharacters(in: .whitespaces)
            .lowercased()

        let frenchPrefixes = [
            "trophées d'",
            "trophées de ",
            "trophées du ",
            "trophées des ",
            "trophées "
        ]
        for prefix in frenchPrefixes {
            if result.hasPrefix(prefix) {
                result = String(result.dropFirst(prefix.count))
                break
            }
        }

        return result
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private func normalizedMatch(_ a: String, _ b: String) -> Bool {
        normalize(a) == normalize(b)
    }

    // MARK: - Sync title

    @discardableResult
    private func syncTitle(_ title: PSNTitle, result: inout PSNSyncResult, force: Bool = false, playtimes: [PSNPlaytime] = []) async throws -> [AchievementUnlock] {
        let serviceName = PSNServiceName(from: title.npServiceName)
        let platforms = platformsFrom(title)
        let primaryPlatform = platforms.first ?? .ps4
        var achievements: [AchievementUnlock] = []

        let matchedPlaytime = playtimes.first(where: {
            normalizedMatch($0.name ?? "", title.trophyTitleName)
        })

        if let index = await MainActor.run(body: {
            store.games.firstIndex(where: { $0.psnCommunicationId == title.npCommunicationId })
        }) {
            let game = await MainActor.run { store.games[index] }

            if !force && !shouldSync(title, game: game) {
                if let playtime = matchedPlaytime {
                    var updatedGame = game
                    updatedGame.playDuration = playtime.playDuration
                    updatedGame.playCount = playtime.playCount
                    updatedGame.firstPlayedDateTime = playtime.firstPlayedDateTime
                    updatedGame.lastPlayedDateTime = playtime.lastPlayedDateTime
                    await MainActor.run { store.games[index] = updatedGame }
                }
                result.skipped += 1
                return []
            }

            var groupNameMap: [String: String] = [:]
            var groupIconMap: [String: String] = [:]

            if title.hasTrophyGroups {
                if let groups = try? await apiService.fetchTrophyGroups(
                    npCommunicationId: title.npCommunicationId,
                    serviceName: serviceName
                ) {
                    groupNameMap = buildGroupNameMap(from: groups)
                    groupIconMap = buildGroupIconMap(from: groups)
                }
            }

            var updatedGame = game
            updatedGame.platforms = platforms
            updatedGame.psnProgress = title.progress
            if let dateString = title.lastUpdatedDateTime,
               let date = ISO8601DateFormatter().date(from: dateString) {
                updatedGame.lastUpdate = date
            }
            if let playtime = matchedPlaytime {
                updatedGame.playDuration = playtime.playDuration
                updatedGame.playCount = playtime.playCount
                updatedGame.firstPlayedDateTime = playtime.firstPlayedDateTime
                updatedGame.lastPlayedDateTime = playtime.lastPlayedDateTime
            }

            try await syncTrophies(into: &updatedGame, title: title, serviceName: serviceName, groupNameMap: groupNameMap, groupIconMap: groupIconMap)

            let existingExtNames = Set(game.extensions.map { $0.name })
            let newExtensions = updatedGame.extensions.filter {
                $0.name != "Base Game" && !existingExtNames.contains($0.name)
            }
            for ext in newExtensions {
                await NotificationService.shared.sendNewDLCNotification(
                    dlcName: ext.name,
                    gameName: updatedGame.title,
                    communicationId: updatedGame.psnCommunicationId ?? ""
                )
            }

            let hadPlatinum = game.hasPlatinum
            let hadHundredPercent = game.completionPercentage == 100
            let hasPlatinumNow = updatedGame.hasPlatinum
            let hasHundredPercentNow = updatedGame.completionPercentage == 100
            let hasExtensions = updatedGame.extensions.count > 1

            if !hadPlatinum && hasPlatinumNow {
                achievements.append(AchievementUnlock(type: .platinum, game: updatedGame))
            }

            if !hadHundredPercent && hasHundredPercentNow {
                if !hasPlatinumNow || hasExtensions {
                    achievements.append(AchievementUnlock(type: .hundredPercent, game: updatedGame))
                }
            }

            await MainActor.run { store.games[index] = updatedGame }
            result.updated += 1

        } else {
            var groupNameMap: [String: String] = [:]
            var groupIconMap: [String: String] = [:]

            if title.hasTrophyGroups {
                if let groups = try? await apiService.fetchTrophyGroups(
                    npCommunicationId: title.npCommunicationId,
                    serviceName: serviceName
                ) {
                    groupNameMap = buildGroupNameMap(from: groups)
                    groupIconMap = buildGroupIconMap(from: groups)
                }
            }

            var game = buildGame(from: title, primaryPlatform: primaryPlatform, platforms: platforms)
            if let playtime = matchedPlaytime {
                game.playDuration = playtime.playDuration
                game.playCount = playtime.playCount
                game.firstPlayedDateTime = playtime.firstPlayedDateTime
                game.lastPlayedDateTime = playtime.lastPlayedDateTime
            }
            try await syncTrophies(into: &game, title: title, serviceName: serviceName, groupNameMap: groupNameMap, groupIconMap: groupIconMap)
            await MainActor.run { store.games.append(game) }
            result.added += 1
        }

        return achievements
    }

    private func buildGame(from title: PSNTitle, primaryPlatform: Platform, platforms: [Platform]) -> Game {
        var game = Game(title: title.trophyTitleName, platform: primaryPlatform)
        game.platforms = platforms
        game.psnCommunicationId = title.npCommunicationId
        game.psnServiceName = title.npServiceName
        game.psnProgress = title.progress
        if let iconUrl = title.trophyTitleIconUrl {
            game.coverURL = URL(string: iconUrl)
        }
        if let dateString = title.lastUpdatedDateTime,
           let date = ISO8601DateFormatter().date(from: dateString) {
            game.lastUpdate = date
        }
        game.status = .playing
        return game
    }

    private func buildGroupNameMap(from groups: [PSNTrophyGroup]) -> [String: String] {
        var map: [String: String] = [:]
        for group in groups {
            let id = group.trophyGroupId
            if id == "default" {
                map[id] = "Base Game"
            } else if let name = group.trophyGroupName, !name.isEmpty {
                map[id] = name
            } else {
                map[id] = "DLC \(id)"
            }
        }
        return map
    }

    private func buildGroupIconMap(from groups: [PSNTrophyGroup]) -> [String: String] {
        var map: [String: String] = [:]
        for group in groups {
            if let iconUrl = group.trophyGroupIconUrl {
                let name = group.trophyGroupId == "default"
                    ? "Base Game"
                    : (group.trophyGroupName ?? "DLC \(group.trophyGroupId)")
                map[name] = iconUrl
            }
        }
        return map
    }

    private func extensionName(for groupId: String?, groupNameMap: [String: String]) -> String {
        guard let groupId else { return "Base Game" }
        return groupNameMap[groupId] ?? (groupId == "default" ? "Base Game" : "DLC \(groupId)")
    }

    private func syncTrophies(into game: inout Game, title: PSNTitle, serviceName: PSNServiceName, groupNameMap: [String: String], groupIconMap: [String: String]) async throws {
        let definitions = try await apiService.fetchTrophyDefinitions(
            npCommunicationId: title.npCommunicationId,
            serviceName: serviceName
        )
        let earned = try await apiService.fetchEarnedTrophies(
            npCommunicationId: title.npCommunicationId,
            serviceName: serviceName
        )

        let earnedMap = Dictionary(uniqueKeysWithValues: earned.map { ($0.trophyId, $0) })

        game.trophies = definitions.map { def in
            var trophy = Trophy(
                name: def.trophyName ?? "Unknown",
                type: TrophyType(fromPSN: def.trophyType),
                extension_: extensionName(for: def.trophyGroupId, groupNameMap: groupNameMap)
            )
            trophy.psnTrophyId = def.trophyId
            trophy.trophyDescription = def.trophyDetail
            trophy.isHidden = def.trophyHidden
            trophy.iconUrl = def.trophyIconUrl

            if let target = def.trophyProgressTargetValue {
                trophy.progressTarget = Int(target)
            }

            if let earnedTrophy = earnedMap[def.trophyId] {
                trophy.isUnlocked = earnedTrophy.earned ?? false
                if let dateString = earnedTrophy.earnedDateTime {
                    trophy.unlockedDate = ISO8601DateFormatter().date(from: dateString)
                }
                if let rateString = earnedTrophy.trophyEarnedRate {
                    trophy.earnedRate = Double(rateString)
                }
                trophy.rarity = earnedTrophy.trophyRare

                if !(earnedTrophy.earned ?? false) {
                    if let progress = earnedTrophy.progress {
                        trophy.progressValue = Int(progress)
                    }
                    if let progressRate = earnedTrophy.progressRate {
                        trophy.progressRate = progressRate
                    }
                } else if trophy.progressTarget != nil {
                    trophy.progressValue = trophy.progressTarget
                    trophy.progressRate = 100
                }
            }
            return trophy
        }

        let extensionNames = game.trophies.map { $0.extension_ }
        var seen = Set<String>()
        let uniqueExtensions = extensionNames.filter { seen.insert($0).inserted }
        let baseFirst = ["Base Game"] + uniqueExtensions.filter { $0 != "Base Game" }
        game.extensions = baseFirst.map { extName in
            GameExtension(name: extName, iconUrl: groupIconMap[extName])
        }
    }

    // MARK: - Helpers

    private func platformsFrom(_ title: PSNTitle) -> [Platform] {
        let parts = title.trophyTitlePlatform
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).uppercased() }

        var platforms: [Platform] = []
        for part in parts {
            if part.contains("PS5")                                   { platforms.append(.ps5) }
            else if part.contains("PS3")                              { platforms.append(.ps3) }
            else if part.contains("PSVITA") || part.contains("VITA")  { platforms.append(.vita) }
            else if part.contains("PS4")                              { platforms.append(.ps4) }
        }
        return platforms.isEmpty ? [.ps4] : platforms
    }
}