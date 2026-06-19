//
//  Game.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import Foundation

struct Game: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var platform: Platform
    var platforms: [Platform] = []
    var lastUpdate: Date = Date()
    var coverURL: URL?
    var isFavorite: Bool = false
    var status: GameStatus = .playing
    var psnCommunicationId: String? = nil
    var psnServiceName: String? = nil
    var psnProgress: Int? = nil
    var trophies: [Trophy] = []
    var extensions: [GameExtension] = [GameExtension(name: "Base Game")]

    var allPlatforms: [Platform] {
        platforms.isEmpty ? [platform] : platforms
    }

    var totalTrophies: Int { trophies.count }
    var unlockedTrophies: Int { trophies.filter(\.isUnlocked).count }

    var maxPoints: Int {
        trophies.filter { $0.type != .platinum }.reduce(0) { $0 + $1.type.points }
    }

    var earnedPoints: Int {
        trophies.filter { $0.isUnlocked && $0.type != .platinum }.reduce(0) { $0 + $1.type.points }
    }

    var completionPercentage: Double {
        guard maxPoints > 0 else { return 0 }
        let raw = Double(earnedPoints) / Double(maxPoints) * 100
        if raw > 0 && raw < 1 {
            return 1
        }
        return raw
    }

    var totalPoints: Int {
        trophies.filter(\.isUnlocked).reduce(0) { $0 + $1.type.points }
    }

    var hasPlatinum: Bool {
        trophies.first(where: { $0.type == .platinum && $0.isUnlocked }) != nil
    }

    var hiddenTrophiesCount: Int { trophies.filter(\.isHidden).count }

    var effectiveStatus: GameStatus {
        if completionPercentage == 100 && totalTrophies > 0 {
            return .completed
        } else {
            return .playing
        }
    }

    func count(for type: TrophyType) -> Int {
        trophies.filter { $0.type == type }.count
    }

    func trophies(for extension_: String) -> [Trophy] {
        trophies.filter { $0.extension_ == extension_ }
    }

    func completionPercentage(for extension_: String) -> Double {
        let trophiesForExt = trophies(for: extension_)
        let maxPts = trophiesForExt.filter { $0.type != .platinum }.reduce(0) { $0 + $1.type.points }
        let earnedPts = trophiesForExt.filter { $0.isUnlocked && $0.type != .platinum }.reduce(0) { $0 + $1.type.points }
        guard maxPts > 0 else { return 0 }
        let raw = Double(earnedPts) / Double(maxPts) * 100
        if raw > 0 && raw < 1 {
            return 1
        }
        return raw
    }
}

extension Game: Hashable {
    static func == (lhs: Game, rhs: Game) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension Game {
    enum CodingKeys: String, CodingKey {
        case id, title, platform, platforms
        case coverURL
        case trophies, extensions
        case lastUpdate, addedDate
        case isFavorite, status
        case psnCommunicationId, psnServiceName, psnProgress
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        platform = try container.decode(Platform.self, forKey: .platform)
        platforms = try container.decodeIfPresent([Platform].self, forKey: .platforms) ?? []
        coverURL = try container.decodeIfPresent(URL.self, forKey: .coverURL)
        trophies = try container.decode([Trophy].self, forKey: .trophies)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        status = .playing
        psnCommunicationId = try container.decodeIfPresent(String.self, forKey: .psnCommunicationId)
        psnServiceName = try container.decodeIfPresent(String.self, forKey: .psnServiceName)
        psnProgress = try container.decodeIfPresent(Int.self, forKey: .psnProgress)

        do {
            self.extensions = try container.decode([GameExtension].self, forKey: .extensions)
        } catch {
            if let legacyExtensions = try container.decodeIfPresent([String].self, forKey: .extensions) {
                self.extensions = legacyExtensions.map { GameExtension(name: $0) }
            } else {
                self.extensions = [GameExtension(name: "Base Game")]
            }
        }

        if let lastUpdate = try container.decodeIfPresent(Date.self, forKey: .lastUpdate) {
            self.lastUpdate = lastUpdate
        } else if let addedDate = try container.decodeIfPresent(Date.self, forKey: .addedDate) {
            self.lastUpdate = addedDate
        } else {
            self.lastUpdate = Date()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(platform, forKey: .platform)
        try container.encode(platforms, forKey: .platforms)
        try container.encodeIfPresent(coverURL, forKey: .coverURL)
        try container.encode(trophies, forKey: .trophies)
        try container.encode(extensions, forKey: .extensions)
        try container.encode(lastUpdate, forKey: .lastUpdate)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(psnCommunicationId, forKey: .psnCommunicationId)
        try container.encodeIfPresent(psnServiceName, forKey: .psnServiceName)
        try container.encodeIfPresent(psnProgress, forKey: .psnProgress)
    }
}