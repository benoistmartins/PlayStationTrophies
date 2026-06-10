//
//  PSNTrophySummary.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

struct PSNTrophySummary: Codable {
    let level: Int
    let progress: Int
    let earnedTrophies: PSNTrophyCount
}
