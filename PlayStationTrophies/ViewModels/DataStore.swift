//
//  DataStore.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import Foundation
import Combine
import SwiftUI

final class DataStore: ObservableObject {
    @Published var games: [Game] = []

    private let saveURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("games.json")
    }()

    init() {
        Task { await loadAsync() }
    }

    // MARK: - Public

    func updateGame(_ game: Game, updateTimestamp: Bool = false) {
        guard let index = games.firstIndex(where: { $0.id == game.id }) else { return }
        var g = game
        if updateTimestamp {
            g.lastUpdate = Date()
        }
        games[index] = g
        save()
    }

    func savePublic() {
        save()
    }

    // MARK: - Global stats

    var totalPointsAllGames: Int {
        games.reduce(0) { $0 + $1.totalPoints }
    }

    var totalPlatinums: Int {
        games.reduce(0) { $0 + ($1.hasPlatinum ? 1 : 0) }
    }

    var totalUnlockedTrophies: Int {
        games.reduce(0) { $0 + $1.unlockedTrophies }
    }

    var playerLevel: PlayerLevel {
        PlayerLevel.current(for: totalPointsAllGames)
    }

    var completedGames: Int {
        games.filter { $0.effectiveStatus == .completed }.count
    }

    var unearnedTrophies: Int {
        games.reduce(0) { $0 + ($1.totalTrophies - $1.unlockedTrophies) }
    }

    var globalCompletionPercentage: Double {
        let total = games.reduce(0) { $0 + $1.totalTrophies }
        let unlocked = games.reduce(0) { $0 + $1.unlockedTrophies }
        guard total > 0 else { return 0 }
        return Double(unlocked) / Double(total) * 100
    }

    var mostActiveMonth: (month: Int, year: Int, count: Int)? {
        let calendar = Calendar.current
        var counts: [String: (month: Int, year: Int, count: Int)] = [:]
        games.flatMap { $0.trophies }.forEach { trophy in
            guard let date = trophy.unlockedDate else { return }
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            let key = "\(year)-\(month)"
            counts[key] = (month: month, year: year, count: (counts[key]?.count ?? 0) + 1)
        }
        return counts.values.max(by: { $0.count < $1.count })
    }

    // MARK: - Platform stats

    var usedPlatforms: [Platform] {
        let platforms = Set(games.flatMap { $0.allPlatforms })
        return Platform.allCases.filter { platforms.contains($0) }
    }

    func games(for platform: Platform) -> [Game] {
        games.filter { $0.allPlatforms.contains(platform) }
    }

    func completedGames(for platform: Platform) -> Int {
        games(for: platform).filter { $0.effectiveStatus == .completed }.count
    }

    func totalTrophies(for platform: Platform) -> Int {
        games(for: platform).reduce(0) { $0 + $1.totalTrophies }
    }

    func unlockedTrophies(for platform: Platform) -> Int {
        games(for: platform).reduce(0) { $0 + $1.unlockedTrophies }
    }

    func unearnedTrophies(for platform: Platform) -> Int {
        totalTrophies(for: platform) - unlockedTrophies(for: platform)
    }

    func totalPoints(for platform: Platform) -> Int {
        games(for: platform).reduce(0) { $0 + $1.totalPoints }
    }

    func platinums(for platform: Platform) -> Int {
        games(for: platform).filter { $0.hasPlatinum }.count
    }

    func completionPercentage(for platform: Platform) -> Double {
        let total = totalTrophies(for: platform)
        guard total > 0 else { return 0 }
        return Double(unlockedTrophies(for: platform)) / Double(total) * 100
    }

    // MARK: - Year stats

    var availableYears: [Int] {
        let calendar = Calendar.current
        let years = Set(
            games.flatMap { $0.trophies }
                .compactMap { $0.unlockedDate }
                .map { calendar.component(.year, from: $0) }
        )
        return years.sorted().reversed()
    }

    func trophiesUnlocked(in year: Int) -> [Trophy] {
        let calendar = Calendar.current
        return games.flatMap { $0.trophies }.filter { trophy in
            guard let date = trophy.unlockedDate else { return false }
            return calendar.component(.year, from: date) == year
        }
    }

    func pointsEarned(in year: Int) -> Int {
        trophiesUnlocked(in: year).reduce(0) { $0 + $1.type.points }
    }

    func platinumsEarned(in year: Int) -> Int {
        trophiesUnlocked(in: year).filter { $0.type == .platinum }.count
    }

    func gamesStarted(in year: Int) -> Int {
        let calendar = Calendar.current
        return games.filter { game in
            game.trophies.contains { trophy in
                guard let date = trophy.unlockedDate else { return false }
                return calendar.component(.year, from: date) == year
            }
        }.count
    }

    // MARK: - Private

    private func save() {
        do {
            let data = try JSONEncoder().encode(games)
            try data.write(to: saveURL, options: .atomic)
        } catch {
            print("❌ DataStore | Save error: \(error)")
        }
    }

    private func loadAsync() async {
        guard FileManager.default.fileExists(atPath: saveURL.path) else { return }
        do {
            let data = try Data(contentsOf: saveURL)
            let decoded = try JSONDecoder().decode([Game].self, from: data)
            await MainActor.run { self.games = decoded }
        } catch {
            print("❌ DataStore | Load error: \(error)")
        }
    }
}
