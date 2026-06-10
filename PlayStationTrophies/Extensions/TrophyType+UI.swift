//
//  TrophyType+UI.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import SwiftUI

extension TrophyType {
    var color: Color {
        switch self {
        case .bronze:   return .brown
        case .silver:   return .gray
        case .gold:     return .yellow
        case .platinum: return .cyan
        }
    }
}
