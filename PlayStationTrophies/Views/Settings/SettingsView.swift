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
    @Environment(\.dismiss) private var dismiss
    @State private var showDebug = false
    @State private var debugTapCount = 0

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

                Section {
                    EmptyView()
                } footer: {
                    Text("PlayStationTrophies")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            debugTapCount += 1
                            if debugTapCount >= 7 {
                                debugTapCount = 0
                                showDebug = true
                            }
                        }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(isPresented: $showDebug) {
                DebugView(onDismissAll: { dismiss() })
                    .environmentObject(store)
                    .environmentObject(syncViewModel)
            }
        }
    }
}