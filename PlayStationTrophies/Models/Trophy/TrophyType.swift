//
//  TrophyType.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 05/05/2026.
//

import Foundation

// MARK: - TrophyType

enum TrophyType: String, Codable, CaseIterable {
    case bronze   = "Bronze"
    case silver   = "Silver"
    case gold     = "Gold"
    case platinum = "Platinum"

    var icon: String {
        switch self {
        case .bronze:   return "🥉"
        case .silver:   return "🥈"
        case .gold:     return "🥇"
        case .platinum: return "🏆"
        }
    }

    var points: Int {
        switch self {
        case .bronze:   return 15
        case .silver:   return 30
        case .gold:     return 90
        case .platinum: return 300
        }
    }
    
    static var displayOrder: [TrophyType] {
        [.platinum, .gold, .silver, .bronze]
    }
}
