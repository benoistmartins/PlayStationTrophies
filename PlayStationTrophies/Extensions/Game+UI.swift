//
//  Game+UI.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 19/04/2026.
//

import SwiftUI

extension Game {
    var progressColor: Color {
        switch completionPercentage {
        case 90...:  return .blue
        case 60...:  return .green
        case 30...:  return .orange
        default:     return .red
        }
    }

    func completionColor(for extension_: String) -> Color {
        let percentage = completionPercentage(for: extension_)
        switch percentage {
        case 90...:  return .blue
        case 60...:  return .green
        case 30...:  return .orange
        default:     return .red
        }
    }

    // MARK: - Completion timing

    var firstTrophyDate: Date? {
        trophies.compactMap { $0.unlockedDate }.min()
    }

    var platinumDate: Date? {
        trophies.first(where: { $0.type == .platinum && $0.isUnlocked })?.unlockedDate
    }

    var lastTrophyDate: Date? {
        trophies.compactMap { $0.unlockedDate }.max()
    }

    func completionDuration(from start: Date, to end: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: start, to: end)

        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0

        func plural(_ value: Int, _ unit: String) -> String {
            "\(value) \(unit)\(value == 1 ? "" : "s")"
        }

        if years > 0 {
            return months > 0
                ? "\(plural(years, "year")) \(plural(months, "month"))"
                : plural(years, "year")
        }
        if months > 0 {
            return days > 0
                ? "\(plural(months, "month")) \(plural(days, "day"))"
                : plural(months, "month")
        }
        if days > 0 {
            return hours > 0
                ? "\(plural(days, "day")) \(plural(hours, "hour"))"
                : plural(days, "day")
        }
        if hours > 0 {
            return minutes > 0
                ? "\(plural(hours, "hour")) \(plural(minutes, "minute"))"
                : plural(hours, "hour")
        }
        if minutes > 0 {
            return plural(minutes, "minute")
        }
        return "Less than a minute"
    }
}