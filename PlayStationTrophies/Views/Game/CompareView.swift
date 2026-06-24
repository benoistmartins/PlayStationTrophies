//
//  CompareView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 23/06/2026.
//

import SwiftUI

struct CompareView: View {
    let game: Game
    @EnvironmentObject private var psnContainer: PSNServiceContainer
    @EnvironmentObject private var profileStore: ProfileStore
    @Environment(\.dismiss) private var dismiss

    @State private var psnId = ""
    @State private var isLoading = false
    @State private var error: String? = nil
    @State private var compareResult: CompareResult? = nil
    @State private var comparedWith = ""

    private let historyKey = "compare_psn_history"

    private var history: [String] {
        UserDefaults.standard.stringArray(forKey: historyKey) ?? []
    }

    private var comparisons: [ComparisonGroup: [TrophyComparison]] {
        compareResult?.comparisons ?? [:]
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("PSN ID", text: $psnId)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                        if isLoading {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Button {
                                Task { await compare() }
                            } label: {
                                Text("Compare")
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                            }
                            .disabled(psnId.isEmpty)
                        }
                    }
                } footer: {
                    if let error {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }

                let filteredHistory = history.filter {
                    psnId.isEmpty || $0.localizedCaseInsensitiveContains(psnId)
                }
                if !filteredHistory.isEmpty && compareResult == nil {
                    Section("Recent searches") {
                        ForEach(filteredHistory, id: \.self) { id in
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                                Text(id)
                                Spacer()
                                Image(systemName: "arrow.up.left")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                psnId = id
                                Task { await compare() }
                            }
                        }
                        .onDelete { indexSet in
                            var current = history
                            current.remove(atOffsets: indexSet)
                            UserDefaults.standard.set(current, forKey: historyKey)
                        }
                    }
                }

                if let result = compareResult {
                    Section {
                        HStack(spacing: 0) {
                            VStack(spacing: 6) {
                                avatarView(url: profileStore.profile.avatarURL, size: 44)
                                Text("You")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(game.unlockedTrophies)")
                                    .font(.title2.bold())
                                Text("trophies")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.0f%%", game.completionPercentage))
                                    .font(.caption.bold())
                                    .foregroundStyle(game.progressColor)
                            }
                            .frame(maxWidth: .infinity)

                            Text("VS")
                                .font(.headline.bold())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)

                            VStack(spacing: 6) {
                                avatarView(url: result.friendAvatarUrl, size: 44)
                                Text(comparedWith)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                Text("\(result.friendTrophyCount)")
                                    .font(.title2.bold())
                                Text("trophies")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.0f%%", result.friendCompletionPercentage))
                                    .font(.caption.bold())
                                    .foregroundStyle(Game.progressColor(for: result.friendCompletionPercentage))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 8)
                    }

                    comparisonGroup(
                        title: "Both earned",
                        icon: "checkmark.circle.fill",
                        color: .green,
                        group: .bothEarned
                    )
                    comparisonGroup(
                        title: "You earned, \(comparedWith) didn't",
                        icon: "person.fill.checkmark",
                        color: .blue,
                        group: .onlyMe
                    )
                    comparisonGroup(
                        title: "\(comparedWith) earned, you didn't",
                        icon: "person.fill.xmark",
                        color: .orange,
                        group: .onlyThem
                    )
                    comparisonGroup(
                        title: "Neither earned",
                        icon: "xmark.circle",
                        color: .secondary,
                        group: .neitherEarned
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(compareResult != nil
                         ? "\(game.title) - Compare with \(comparedWith)"
                         : "\(game.title) - Compare with a friend")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func avatarView(url: URL?, size: CGFloat) -> some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var avatarPlaceholder: some View {
        ZStack {
            Circle().fill(Color(.systemGray5))
            Image(systemName: "person.fill")
                .foregroundStyle(.secondary)
                .font(.title3)
        }
    }

    @ViewBuilder
    private func comparisonGroup(title: String, icon: String, color: Color, group: ComparisonGroup) -> some View {
        let trophies = comparisons[group] ?? []
        if !trophies.isEmpty {
            Section {
                ForEach(trophies, id: \.trophy.id) { comparison in
                    TrophyRowView(
                        trophy: comparison.trophy,
                        isRevealed: true
                    ) {}
                }
            } header: {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text("\(title): \(trophies.count)")
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }
            }
        }
    }

    private func compare() async {
        isLoading = true
        error = nil
        compareResult = nil
        do {
            let compareService = PSNCompareService(apiService: psnContainer.apiService)
            compareResult = try await compareService.compare(game: game, withPSNId: psnId)
            comparedWith = psnId
            saveToHistory(psnId)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    private func saveToHistory(_ id: String) {
        var current = history.filter { $0 != id }
        current.insert(id, at: 0)
        if current.count > 10 {
            current = Array(current.prefix(10))
        }
        UserDefaults.standard.set(current, forKey: historyKey)
    }
}
