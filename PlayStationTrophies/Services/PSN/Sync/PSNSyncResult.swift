//
//  PSNSyncResult.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

struct PSNSyncResult {
    var added: Int = 0
    var updated: Int = 0
    var skipped: Int = 0
    var errors: [String] = []

    var hasErrors: Bool { !errors.isEmpty }
}