//
//  TrophySort.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 07/06/2026.
//

import Foundation

enum TrophySort: String, CaseIterable {
    case defaultOrder = "Default"
    case notEarned    = "Not earned"
    case rarity       = "Rarity"
    case earnedDate   = "Date earned"
    case rank         = "Rank"
}