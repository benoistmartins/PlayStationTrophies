//
//  RecentTrophyCell.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 06/06/2026.
//

import SwiftUI

struct RecentTrophyCell: View {
    let trophy: Trophy
    let game: Game

    var body: some View {
        HStack(spacing: 12) {
            // Image du trophée
            Group {
                if let iconUrlString = trophy.iconUrl,
                   let iconUrl = URL(string: iconUrlString) {
                    AsyncImage(url: iconUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            trophyPlaceholder
                        }
                    }
                } else {
                    trophyPlaceholder
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                // Ligne 1 — type + nom du trophée
                HStack(spacing: 4) {
                    Image(systemName: "trophy.fill")
                        .font(.caption2)
                        .foregroundStyle(trophy.type.color)
                    Text(trophy.name)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                }

                // Ligne 2 — description
                Text(trophy.trophyDescription ?? " ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                // Ligne 3 — date + jeu
                HStack(spacing: 4) {
                    if let date = trophy.unlockedDate {
                        Text(relativeDate(date))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text("in")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    CoverImageView(url: game.coverURL, size: CGSize(width: 14, height: 14))
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                    Text(game.title)
                        .font(.caption2.bold())
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(width: 320, height: 80)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale.current
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private var trophyPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
            Image(systemName: "trophy.fill")
                .foregroundStyle(trophy.type.color)
                .font(.title3)
        }
    }
}
