//
//  GameStatus.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 28/04/2026.
//

import Foundation

enum GameStatus: String, Codable, CaseIterable {
    case playing   = "Playing"
    case completed = "Completed"
}
