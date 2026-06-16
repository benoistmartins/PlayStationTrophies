//
//  TrophyFilter.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/06/2026.
//

import Foundation

enum TrophyFilter: String, CaseIterable {
    case all        = "All"
    case notEarned  = "Not earned"
    case inProgress = "In progress"
    case earned     = "Earned"
    case platinum   = "Platinum"
    case gold       = "Gold"
    case silver     = "Silver"
    case bronze     = "Bronze"

    var isDefault: Bool { self == .all }
}