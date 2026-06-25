//
//  DebugView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 20/04/2026.
//

import SwiftUI

struct DebugView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var syncViewModel: PSNSyncViewModel
    let onDismissAll: () -> Void

    @State private var selectedGame: Game? = nil

    var body: some View {
        List {
            Section("Game selection") {
                if store.games.isEmpty {
                    Text("No games available")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Select a game", selection: $selectedGame) {
                        Text("None").tag(Optional<Game>.none)
                        ForEach(store.games.sorted { $0.title < $1.title }) { game in
                            Text(game.title).tag(Optional(game))
                        }
                    }
                }
            }

            Section("Achievement Popup") {
                Button("Test Platinum popup") {
                    let game = selectedGame
                        ?? store.games.first(where: { $0.hasPlatinum })
                        ?? store.games.first
                    if let game {
                        onDismissAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            syncViewModel.pendingAchievements = [
                                AchievementUnlock(type: .platinum, game: game)
                            ]
                        }
                    }
                }
                .disabled(store.games.isEmpty)

                Button("Test 100% popup") {
                    let game = selectedGame
                        ?? store.games.first(where: { $0.completionPercentage == 100 })
                        ?? store.games.first
                    if let game {
                        onDismissAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            syncViewModel.pendingAchievements = [
                                AchievementUnlock(type: .hundredPercent, game: game)
                            ]
                        }
                    }
                }
                .disabled(store.games.isEmpty)

                Button("Test Platinum + 100% popup") {
                    let game = selectedGame
                        ?? store.games.first(where: { $0.hasPlatinum })
                        ?? store.games.first
                    if let game {
                        onDismissAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            syncViewModel.pendingAchievements = [
                                AchievementUnlock(type: .platinum, game: game),
                                AchievementUnlock(type: .hundredPercent, game: game)
                            ]
                        }
                    }
                }
                .disabled(store.games.isEmpty)
            }

            Section("Notifications") {
                Button("Test DLC notification") {
                    Task {
                        await NotificationService.shared.sendNewDLCNotification(
                            dlcName: "Left Behind",
                            gameName: "The Last of Us Part I",
                            communicationId: "NPWR38792_00"
                        )
                    }
                }
            }
        }
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.inline)
    }
}