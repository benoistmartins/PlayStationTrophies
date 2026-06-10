//
//  GameRowView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 17/04/2026.
//

import SwiftUI

struct GameRowView: View {
    let gameId: UUID
    @EnvironmentObject private var store: DataStore

    private var game: Game? {
        store.games.first(where: { $0.id == gameId })
    }

    var body: some View {
        if let game {
            HStack(spacing: 12) {
                CoverImageView(url: game.coverURL, size: CGSize(width: 56, height: 56))

                VStack(alignment: .leading, spacing: 8) {
                    Text(game.title)
                        .font(.headline)
                    HStack(spacing: 6) {
                        ForEach(game.allPlatforms, id: \.self) { platform in
                            PlatformBadge(platform: platform)
                        }
                    }

                    ProgressView(value: game.completionPercentage, total: 100)
                        .tint(game.progressColor)

                    HStack {
                        Text("\(game.unlockedTrophies) / \(game.totalTrophies) trophies")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(String(format: "%.0f%%", game.completionPercentage))
                            .font(.caption.bold())
                            .foregroundStyle(game.progressColor)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}