//
//  SettingsView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 20/04/2026.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var authViewModel: PSNAuthViewModel
    @EnvironmentObject private var syncViewModel: PSNSyncViewModel
    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            Label(theme.rawValue, systemImage: theme.icon)
                            Spacer()
                            if appTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { appTheme = theme }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
