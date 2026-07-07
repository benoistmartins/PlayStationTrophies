//
//  PSNPlaytimeResponse.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 28/06/2026.
//

import Foundation

struct PSNPlaytimeResponse: Codable {
    let titles: [PSNPlaytime]
    let totalItemCount: Int?
}