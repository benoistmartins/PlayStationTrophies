//
//  SortOrder.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/07/2026.
//

import Foundation

enum SortOrder {
    case ascending, descending

    mutating func toggle() {
        self = self == .ascending ? .descending : .ascending
    }

    var icon: String {
        self == .ascending ? "chevron.up" : "chevron.down"
    }
}
