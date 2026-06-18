//
//  AchievementUnlock.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 17/04/2026.
//

import Foundation

struct AchievementUnlock: Identifiable {
    let id = UUID()
    let type: AchievementUnlockType
    let game: Game
}