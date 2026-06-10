//
//  PSNTitleResponse.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

struct PSNTitleResponse: Codable {
    let trophyTitles: [PSNTitle]
    let nextOffset: Int?
    let totalItemCount: Int?
}
