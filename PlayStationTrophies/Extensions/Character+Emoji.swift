//
//  Character+Emoji.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 27/04/2026.
//

import Foundation

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && scalar.value > 0x238C
    }
}
