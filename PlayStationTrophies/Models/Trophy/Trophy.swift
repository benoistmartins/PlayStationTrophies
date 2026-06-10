//
//  Trophy.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 17/04/2026.
//

import Foundation

struct Trophy: Identifiable, Codable {
    var id: UUID = UUID()
    var psnTrophyId: Int? = nil
    var name: String
    var type: TrophyType
    var trophyDescription: String? = nil
    var isUnlocked: Bool = false
    var unlockedDate: Date? = nil
    var isHidden: Bool = false
    var extension_: String = "Base Game"
    var iconUrl: String? = nil
    var earnedRate: Double? = nil
    var rarity: Int? = nil
    var progressValue: Int? = nil
    var progressTarget: Int? = nil
    var progressRate: Int? = nil

    init(name: String, type: TrophyType, extension_: String = "Base Game") {
        self.name = name
        self.type = type
        self.extension_ = extension_
    }

    init(name: String, type: TrophyType, extension_: String = "Base Game", trophyDescription: String? = nil) {
        self.name = name
        self.type = type
        self.extension_ = extension_
        self.trophyDescription = trophyDescription
    }

    enum CodingKeys: String, CodingKey {
        case id, psnTrophyId, name, type, trophyDescription
        case isUnlocked, unlockedDate, isHidden, extension_
        case iconUrl, earnedRate, rarity
        case progressValue, progressTarget, progressRate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        psnTrophyId = try container.decodeIfPresent(Int.self, forKey: .psnTrophyId)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(TrophyType.self, forKey: .type)
        trophyDescription = try container.decodeIfPresent(String.self, forKey: .trophyDescription)
        isUnlocked = try container.decodeIfPresent(Bool.self, forKey: .isUnlocked) ?? false
        unlockedDate = try container.decodeIfPresent(Date.self, forKey: .unlockedDate)
        isHidden = try container.decodeIfPresent(Bool.self, forKey: .isHidden) ?? false
        extension_ = try container.decodeIfPresent(String.self, forKey: .extension_) ?? "Base Game"
        iconUrl = try container.decodeIfPresent(String.self, forKey: .iconUrl)
        earnedRate = try container.decodeIfPresent(Double.self, forKey: .earnedRate)
        rarity = try container.decodeIfPresent(Int.self, forKey: .rarity)
        progressValue = try container.decodeIfPresent(Int.self, forKey: .progressValue)
        progressTarget = try container.decodeIfPresent(Int.self, forKey: .progressTarget)
        progressRate = try container.decodeIfPresent(Int.self, forKey: .progressRate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(psnTrophyId, forKey: .psnTrophyId)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(trophyDescription, forKey: .trophyDescription)
        try container.encode(isUnlocked, forKey: .isUnlocked)
        try container.encodeIfPresent(unlockedDate, forKey: .unlockedDate)
        try container.encode(isHidden, forKey: .isHidden)
        try container.encode(extension_, forKey: .extension_)
        try container.encodeIfPresent(iconUrl, forKey: .iconUrl)
        try container.encodeIfPresent(earnedRate, forKey: .earnedRate)
        try container.encodeIfPresent(rarity, forKey: .rarity)
        try container.encodeIfPresent(progressValue, forKey: .progressValue)
        try container.encodeIfPresent(progressTarget, forKey: .progressTarget)
        try container.encodeIfPresent(progressRate, forKey: .progressRate)
    }
}
