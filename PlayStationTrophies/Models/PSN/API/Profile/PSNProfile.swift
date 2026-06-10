//
//  PSNProfile.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

struct PSNProfile: Codable {
    let onlineId: String
    let aboutMe: String?
    let avatars: [PSNAvatar]
    let isPlus: Bool
    let personalDetail: PSNPersonalDetail?

    var avatarUrl: String? {
        avatars.first(where: { $0.size == "xl" })?.url
            ?? avatars.first?.url
    }
}