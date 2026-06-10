//
//  SearchFilter.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 20/04/2026.
//

import Foundation

struct SearchFilter {
    var name: String = ""
    var platforms: Set<Platform> = []
    var platinumFilter: PlatinumFilter = .all
    var progressionFilter: ProgressionFilter = .all

    var isEmpty: Bool {
        name.isEmpty &&
        platforms.isEmpty &&
        platinumFilter == .all &&
        progressionFilter == .all
    }
}