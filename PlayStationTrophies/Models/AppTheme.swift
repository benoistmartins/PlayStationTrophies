//
//  AppTheme.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 25/04/2026.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Codable {
    case system = "System"
    case light  = "Light"
    case dark   = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max"
        case .dark:   return "moon"
        }
    }
}
