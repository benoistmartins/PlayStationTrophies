//
//  RecentTrophiesView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 06/06/2026.
//

import SwiftUI

struct RecentTrophiesView: View {
    @EnvironmentObject private var store: DataStore

    private var recentTrophies: [(trophy: Trophy, game: Game)] {
        store.games
            .flatMap { game in
                game.trophies
                    .filter { $0.isUnlocked && $0.unlockedDate != nil }
                    .map { (trophy: $0, game: game) }
            }
            .sorted { $0.trophy.unlockedDate! > $1.trophy.unlockedDate! }
            .prefix(12)
            .map { $0 }
    }

    var body: some View {
        if recentTrophies.isEmpty { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent trophies")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(recentTrophies, id: \.trophy.id) { item in
                            RecentTrophyCell(trophy: item.trophy, game: item.game)
                        }
                    }
                    .padding(.horizontal)
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
            }
            .padding(.vertical, 8)
        )
    }
}
