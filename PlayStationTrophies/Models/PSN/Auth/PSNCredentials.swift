//
//  PSNCredentials.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

struct PSNCredentials: Codable {
    var accessToken: String
    var refreshToken: String
    var accessTokenExpiry: Date
    var refreshTokenExpiry: Date

    var isAccessTokenValid: Bool {
        Date() < accessTokenExpiry
    }

    var isRefreshTokenValid: Bool {
        Date() < refreshTokenExpiry
    }
}
