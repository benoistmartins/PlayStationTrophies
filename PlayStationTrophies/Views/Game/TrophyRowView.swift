//
//  TrophyRowView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 17/04/2026.
//

import SwiftUI

struct TrophyRowView: View {
    let trophy: Trophy
    let isRevealed: Bool
    let onReveal: () -> Void

    private var shouldHide: Bool {
        trophy.isHidden && !trophy.isUnlocked && !isRevealed
    }

    private var progressPercentage: Double? {
        guard let rate = trophy.progressRate,
              trophy.progressTarget != nil,
              rate > 0,
              !trophy.isUnlocked else { return nil }
        return Double(rate) / 100.0
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(.dateTime
            .day()
            .month(.abbreviated)
            .year()
            .hour(.defaultDigits(amPM: .omitted))
            .minute()
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            trophyIcon
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(shouldHide ? "Hidden trophy" : trophy.name)
                        .font(.body)
                        .foregroundStyle(trophy.isUnlocked ? .primary : .secondary)
                        .italic(shouldHide)
                    if trophy.isHidden && !shouldHide {
                        Image(systemName: "eye.slash")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if !shouldHide {
                    if let description = trophy.trophyDescription, !description.isEmpty {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let percentage = progressPercentage,
                       let current = trophy.progressValue,
                       let target = trophy.progressTarget,
                       let rate = trophy.progressRate {
                        VStack(alignment: .leading, spacing: 3) {
                            ProgressView(value: percentage)
                                .tint(Color.blue)
                            HStack {
                                Text("\(current) / \(target)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(rate)%")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color.blue)
                            }
                        }
                        .padding(.top, 2)
                    }
                }

                if let date = trophy.unlockedDate {
                    Text("Unlocked \(formattedDate(date))")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                if let rate = trophy.earnedRate {
                    HStack(spacing: 2) {
                        Image(systemName: "person.2.fill")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text(String(format: "%.1f%%", rate))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Spacer()

            if shouldHide {
                Button {
                    onReveal()
                } label: {
                    Image(systemName: "eye")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            } else {
                trophyTypeIcon
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Trophy icon

    @ViewBuilder
    private var trophyIcon: some View {
        if shouldHide {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }
        } else if !trophy.isUnlocked {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray5))
                if let iconUrlString = trophy.iconUrl,
                   let iconUrl = URL(string: iconUrlString) {
                    AsyncImage(url: iconUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .grayscale(1.0)
                                .opacity(0.35)
                        default:
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                        }
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
            }
        } else {
            if let iconUrlString = trophy.iconUrl,
               let iconUrl = URL(string: iconUrlString) {
                AsyncImage(url: iconUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        trophyTypePlaceholder
                    case .empty:
                        ProgressView().frame(width: 44, height: 44)
                    @unknown default:
                        trophyTypePlaceholder
                    }
                }
            } else {
                trophyTypePlaceholder
            }
        }
    }

    private var trophyTypePlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
            Image(systemName: "trophy.fill")
                .foregroundStyle(trophy.type.color)
                .font(.title3)
        }
    }

    private var trophyTypeIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(trophy.type.color.opacity(0.15))
            Image(systemName: "trophy.fill")
                .foregroundStyle(trophy.type.color)
                .font(.title3)
        }
        .opacity(trophy.isUnlocked ? 1 : 0.4)
    }
}
