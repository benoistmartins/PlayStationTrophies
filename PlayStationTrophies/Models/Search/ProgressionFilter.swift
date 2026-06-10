//
//  ProgressionFilter.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 20/04/2026.
//

import Foundation

enum ProgressionFilter: String, CaseIterable {
    case all = "All"
    case completed = "100%"
    case notCompleted = "Not 100%"
    case notCompletedOrPlatinum = "Not 100% or Platinum"
    case platinumed = "Platinum"
    case platinumedNotCompleted = "Platinum, not 100%"
}
