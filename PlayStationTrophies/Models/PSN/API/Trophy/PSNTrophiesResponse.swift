//
//  PSNTrophiesResponse.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

struct PSNTrophiesResponse: Codable {
    let trophies: [PSNTrophy]
    let totalItemCount: Int?
}