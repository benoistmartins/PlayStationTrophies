//
//  PlayStationTrophiesApp.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import SwiftUI
import UserNotifications

@main
struct PlayStationTrophiesApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var profileStore = ProfileStore()
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var isLaunching = true
    @State private var navigateToGameId: UUID? = nil
    private let psnContainer: PSNServiceContainer
    @ObservedObject private var syncViewModel: PSNSyncViewModel

    init() {
        let store = DataStore()
        let profileStore = ProfileStore()
        let container = PSNServiceContainer(store: store, profileStore: profileStore)
        self.psnContainer = container
        _store = StateObject(wrappedValue: store)
        _profileStore = StateObject(wrappedValue: profileStore)
        _syncViewModel = ObservedObject(wrappedValue: container.syncViewModel)

        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            if isLaunching {
                LaunchScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeOut) {
                                isLaunching = false
                            }
                        }
                    }
            } else {
                ZStack {
                    ContentView(navigateToGameId: $navigateToGameId)
                        .environmentObject(store)
                        .environmentObject(profileStore)
                        .environmentObject(psnContainer)
                        .environmentObject(psnContainer.authViewModel)
                        .environmentObject(psnContainer.syncViewModel)
                        .preferredColorScheme(appTheme.colorScheme)

                    if let achievement = syncViewModel.pendingAchievements.first {
                        AchievementPopupView(achievement: achievement) {
                            syncViewModel.dismissFirstAchievement()
                        }
                        .zIndex(999)
                        .transition(.opacity)
                        .animation(.easeInOut, value: syncViewModel.pendingAchievements.count)
                    }
                }
                .task {
                    _ = await NotificationService.shared.requestAuthorization()
                }
                .onAppear {
                    NotificationDelegate.shared.onDLCNotificationTapped = { communicationId in
                        let game = store.games.first(where: { $0.psnCommunicationId == communicationId })
                        navigateToGameId = game?.id
                    }
                }
            }
        }
    }
}