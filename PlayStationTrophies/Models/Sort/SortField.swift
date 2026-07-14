//
//  SortField.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/07/2026.
//

import Foundation

enum SortField: String, CaseIterable {
    case lastUpdate    = "Last Update"
    case name          = "Name"
    case completion    = "Completion"
    case trophyCount   = "Trophy Count"
    case playTime      = "Play Time"
    case lastPlayed    = "Last Played"
    case sessionCount  = "Sessions"
}