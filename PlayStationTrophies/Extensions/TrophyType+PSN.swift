//
//  TrophyType+PSN.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

extension TrophyType {
    init(fromPSN string: String) {
        switch string.lowercased() {
        case "platinum": self = .platinum
        case "gold":     self = .gold
        case "silver":   self = .silver
        default:         self = .bronze
        }
    }
}