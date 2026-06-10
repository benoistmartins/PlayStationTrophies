//
//  PSNTrophyGroup.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/05/2026.
//

import Foundation

struct PSNTrophyGroup: Codable {
    let trophyGroupId: String
    let trophyGroupName: String?
    let trophyGroupIconUrl: String?
    let definedTrophies: PSNTrophyCount?
}
