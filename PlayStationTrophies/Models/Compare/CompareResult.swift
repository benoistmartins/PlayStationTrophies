//
//  CompareResult.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 23/06/2026.
//

import Foundation

struct CompareResult {
    let comparisons: [ComparisonGroup: [TrophyComparison]]
    let friendAvatarUrl: URL?
    let friendTrophyCount: Int
    let friendCompletionPercentage: Double
}