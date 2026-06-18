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

    var body: some View {
        List {
            Section("Achievement Popup") {
                Button("Test Platinum popup") {
                    if let game = store.games.first {
                        onDismissAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            syncViewModel.pendingAchievements = [
                                AchievementUnlock(type: .platinum, game: game)
                            ]
                        }
                    }
                }

                Button("Test 100% popup") {
                    if let game = store.games.first {
                        onDismissAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            syncViewModel.pendingAchievements = [
                                AchievementUnlock(type: .hundredPercent, game: game)
                            ]
                        }
                    }
                }

                Button("Test Platinum + 100% popup") {
                    if let game = store.games.first {
                        onDismissAll()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            syncViewModel.pendingAchievements = [
                                AchievementUnlock(type: .platinum, game: game),
                                AchievementUnlock(type: .hundredPercent, game: game)
                            ]
                        }
                    }
                }
            }

            Section("Notifications") {
                Button("Test DLC notification") {
                    Task {
                        await NotificationService.shared.sendNewDLCNotification(
                            dlcName: "Circulation Libre",
                            gameName: "Mafia: The Old Country",
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
