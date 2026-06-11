//
//  PSNTrophy.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

struct PSNTrophy: Codable {
    let trophyId: Int
    let trophyHidden: Bool
    let trophyType: String
    let trophyName: String?
    let trophyDetail: String?
    let trophyIconUrl: String?
    let trophyGroupId: String?
    let earned: Bool?
    let earnedDateTime: String?
    let trophyRare: Int?
    let trophyEarnedRate: String?
    let trophyProgressTargetValue: String?
    let progress: String?
    let progressRate: Int?
    let progressedDateTime: String?
}
