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
        let totalSeconds = Int(end.timeIntervalSince(start))

        let minutes = totalSeconds / 60
        let hours   = totalSeconds / 3600
        let days    = totalSeconds / 86400
        let weeks   = days / 7
        let remainingDaysAfterWeeks = days % 7
        let remainingHoursAfterWeeks = (totalSeconds - weeks * 7 * 24 * 3600) / 3600

        let components = Calendar.current.dateComponents([.year, .month], from: start, to: end)
        let years  = components.year ?? 0
        let months = components.month ?? 0

        func plural(_ value: Int, _ unit: String) -> String {
            "\(value) \(unit)\(value == 1 ? "" : "s")"
        }

        if years > 0 {
            return months > 0
                ? "\(plural(years, "year")) \(plural(months, "month"))"
                : plural(years, "year")
        }

        if months > 0 {
            let remainingDays = days - (months * 30)
            return remainingDays > 0
                ? "\(plural(months, "month")) \(plural(max(remainingDays, 0), "day"))"
                : plural(months, "month")
        }

        if weeks > 0 {
            if remainingDaysAfterWeeks > 0 {
                return "\(plural(weeks, "week")) \(plural(remainingDaysAfterWeeks, "day"))"
            } else if remainingHoursAfterWeeks > 0 {
                return "\(plural(weeks, "week")) \(plural(remainingHoursAfterWeeks, "hour"))"
            } else {
                return plural(weeks, "week")
            }
        }

        if days > 0 {
            let remainingHours = hours - (days * 24)
            return remainingHours > 0
                ? "\(plural(days, "day")) \(plural(remainingHours, "hour"))"
                : plural(days, "day")
        }

        if hours > 0 {
            let remainingMinutes = minutes - (hours * 60)
            return remainingMinutes > 0
                ? "\(plural(hours, "hour")) \(plural(remainingMinutes, "minute"))"
                : plural(hours, "hour")
        }

        if minutes > 0 {
            return plural(minutes, "minute")
        }

        return "Less than a minute"
    }
}