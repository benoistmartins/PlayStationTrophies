//
//  PSNTitle.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

struct PSNTitle: Codable {
    let npServiceName: String
    let npCommunicationId: String
    let trophySetVersion: String
    let trophyTitleName: String
    let trophyTitleIconUrl: String?
    let trophyTitlePlatform: String
    let hasTrophyGroups: Bool
    let trophyGroupCount: Int?
    let definedTrophies: PSNTrophyCount
    let progress: Int?
    let earnedTrophies: PSNTrophyCount?
    let hiddenFlag: Bool?
    let lastUpdatedDateTime: String?
    let trophyGroups: [PSNTrophyGroup]?
}
