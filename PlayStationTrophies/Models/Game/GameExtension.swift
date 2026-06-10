//
//  GameExtension.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 17/04/2026.
//

import Foundation

struct GameExtension: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var iconUrl: String? = nil

    init(name: String, iconUrl: String? = nil) {
        self.name = name
        self.iconUrl = iconUrl
    }
}
