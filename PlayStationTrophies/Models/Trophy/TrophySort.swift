//
//  TrophySort.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 07/06/2026.
//

import Foundation

enum TrophySort: String, CaseIterable {
    case defaultOrder = "Console"
    case notEarned    = "Not earned"
    case rarity       = "Rarity"
    case earnedDate   = "Date earned"
    case rank         = "Rank"
    case alphabetical = "Alphabetical"
    case earnedRate   = "Earned %"
}