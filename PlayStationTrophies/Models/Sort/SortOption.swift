//
//  SortOption.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import Foundation

struct SortOption {
    var field: SortField = .lastUpdate
    var order: SortOrder = .descending
}