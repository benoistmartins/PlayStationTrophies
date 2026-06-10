//
//  Game+UI.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 19/04/2026.
//

import SwiftUI

extension Game {
    var progressColor: Color {
        switch completionPercentage {
        case 90...:  return .blue
        case 60...:  return .green
        case 30...:  return .orange
        default:     return .red
        }
    }

    func completionColor(for extension_: String) -> Color {
        let percentage = completionPercentage(for: extension_)
        switch percentage {
        case 90...:  return .blue
        case 60...:  return .green
        case 30...:  return .orange
        default:     return .red
        }
    }
}
