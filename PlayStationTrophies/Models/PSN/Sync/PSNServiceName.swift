//
//  PSNServiceName.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

enum PSNServiceName: String {
    case ps4 = "trophy"
    case ps5 = "trophy2"

    init(from string: String) {
        self = string == "trophy2" ? .ps5 : .ps4
    }

    var platform: Platform {
        switch self {
        case .ps4: return .ps4
        case .ps5: return .ps5
        }
    }
}
