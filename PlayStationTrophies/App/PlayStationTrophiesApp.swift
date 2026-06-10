//
//  PlayStationTrophiesApp.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import SwiftUI

@main
struct PlayStationTrophiesApp: App {
    @StateObject private var store = DataStore()
    @StateObject private var profileStore = ProfileStore()
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var isLaunching = true

    private let psnContainer: PSNServiceContainer

    init() {
        let store = DataStore()
        let profileStore = ProfileStore()
        let container = PSNServiceContainer(store: store, profileStore: profileStore)
        self.psnContainer = container
        _store = StateObject(wrappedValue: store)
        _profileStore = StateObject(wrappedValue: profileStore)
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
                ContentView()
                    .environmentObject(store)
                    .environmentObject(profileStore)
                    .environmentObject(psnContainer)
                    .environmentObject(psnContainer.authViewModel)
                    .environmentObject(psnContainer.syncViewModel)
                    .preferredColorScheme(appTheme.colorScheme)
            }
        }
    }
}