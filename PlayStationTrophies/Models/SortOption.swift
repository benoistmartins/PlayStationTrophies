//
//  SortOption.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import Foundation

enum SortField: String, CaseIterable {
    case lastUpdate    = "Last Update"
    case name          = "Name"
    case completion    = "Completion"
    case trophyCount   = "Trophy Count"
}

enum SortOrder {
    case ascending, descending

    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }

    var icon: String {
        self == .ascending ? "chevron.up" : "chevron.down"
    }
}

struct SortOption {
    var field: SortField = .lastUpdate
    var order: SortOrder = .descending
}
