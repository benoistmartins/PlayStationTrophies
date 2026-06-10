//
//  Platform.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 22/04/2026.
//

import Foundation
import SwiftUI

enum Platform: String, Codable, CaseIterable {
    case ps3  = "PS3"
    case ps4  = "PS4"
    case ps5  = "PS5"
    case vita = "PS Vita"

    var color: Color {
        switch self {
        case .ps3:  return Color(red: 0/255, green: 0/255, blue: 0/255)
        case .ps4:  return Color(red: 72/255, green: 160/255, blue: 248/255)
        case .ps5:  return Color(red: 245/255, green: 245/255, blue: 245/255)
        case .vita: return Color(red: 16/255, green: 11/255, blue: 245/255)
        }
    }

    var textColor: Color {
        switch self {
        case .ps5: return .black
        default:   return .white
        }
    }

    var badgeLabel: String {
        switch self {
        case .vita: return "VITA"
        default:    return rawValue
        }
    }
}