//
//  PSNFriendsResponse.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 26/06/2026.
//

import Foundation

struct PSNFriendsResponse: Codable {
    let friends: [String]
    let totalItemCount: Int?
}