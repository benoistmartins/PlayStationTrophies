//
//  ShareCardView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 25/06/2026.
//

import SwiftUI

struct ShareCardView: View {
    let achievement: AchievementUnlock
    let coverImage: UIImage?

    private var title: String {
        switch achievement.type {
        case .platinum:       return "Platinum unlocked! 🏆"
        case .hundredPercent: return "100% completed! ✅"
        }
    }

    private var duration: String? {
        guard let first = achievement.game.firstTrophyDate else { return nil }
        switch achievement.type {
        case .platinum:
            guard let platinum = achievement.game.platinumDate else { return nil }
            return achievement.game.completionDuration(from: first, to: platinum)
        case .hundredPercent:
            guard let last = achievement.game.lastTrophyDate else { return nil }
            return achievement.game.completionDuration(from: first, to: last)
        }
    }

    private var accentColor: Color {
        switch achievement.type {
        case .platinum:       return .cyan
        case .hundredPercent: return .green
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 20) {
                Group {
                    if let coverImage {
                        Image(uiImage: coverImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Color(.systemGray5)
                            Image(systemName: "gamecontroller")
                                .foregroundStyle(.secondary)
                                .font(.largeTitle)
                        }
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: accentColor.opacity(0.5), radius: 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(accentColor, lineWidth: 2)
                )

                VStack(spacing: 6) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundStyle(accentColor)

                    Text(achievement.game.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    if let duration {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                            Text("Completed in \(duration)")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }

                Divider()
                    .background(Color.white.opacity(0.2))

                Text("Trophy hunting with PlayStationTrophies 🎮")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(24)
        }
        .frame(width: 320, height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}