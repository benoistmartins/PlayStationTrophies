//
//  PSNPlaytime.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 28/06/2026.
//

import Foundation

struct PSNPlaytime: Codable {
    let titleId: String
    let name: String?
    let playDuration: String?
    let playCount: Int?
    let firstPlayedDateTime: String?
    let lastPlayedDateTime: String?
}