//
//  PlayerLevel.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 18/04/2026.
//

import Foundation

struct PlayerLevel {
    let level: Int
    let minPoints: Int
    let nextLevelPoints: Int?

    // MARK: - Nouveau système PSN (octobre 2020)

    static func pointsRequired(forLevel level: Int) -> Int {
        switch level {
        case 1...99:   return 60
        case 100...199: return 90
        case 200...299: return 450
        case 300...399: return 900
        case 400...499: return 1350
        case 500...599: return 1800
        case 600...699: return 2250
        case 700...799: return 2700
        case 800...899: return 3150
        case 900...999: return 3600
        default: return 3600
        }
    }

    static func minPoints(forLevel level: Int) -> Int {
        guard level > 1 else { return 0 }
        var total = 0
        for l in 1..<level {
            total += pointsRequired(forLevel: l)
        }
        return total
    }

    static func current(for totalPoints: Int) -> PlayerLevel {
        var level = 1
        var accumulated = 0

        while level < 999 {
            let required = pointsRequired(forLevel: level)
            if accumulated + required > totalPoints {
                break
            }
            accumulated += required
            level += 1
        }

        let currentMin = accumulated
        let nextMin = level < 999 ? accumulated + pointsRequired(forLevel: level) : nil

        return PlayerLevel(
            level: level,
            minPoints: currentMin,
            nextLevelPoints: nextMin
        )
    }

    func progress(currentPoints: Int) -> Double {
        guard let next = nextLevelPoints else { return 1.0 }
        let range = Double(next - minPoints)
        guard range > 0 else { return 1.0 }
        return min(Double(currentPoints - minPoints) / range, 1.0)
    }

    var isMaxLevel: Bool { level == 999 }
}
