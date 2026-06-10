//
//  PSNSyncView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import SwiftUI

struct PSNSyncView: View {
    @EnvironmentObject private var authViewModel: PSNAuthViewModel
    @EnvironmentObject private var syncViewModel: PSNSyncViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                accountSection
                if authViewModel.isAuthenticated {
                    syncSection
                    if let result = syncViewModel.syncResult {
                        resultSection(result)
                    }
                } else {
                    tutorialSection
                }
            }
            .navigationTitle("PSN Sync")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $authViewModel.showLogin) {
            PSNLoginView(viewModel: authViewModel)
                .onDisappear {
                    if authViewModel.isAuthenticated && syncViewModel.canSync {
                        syncViewModel.syncGames(optimized: true)
                    }
                }
        }
        .alert("Error", isPresented: Binding(
            get: { syncViewModel.error != nil },
            set: { if !$0 { syncViewModel.clearError() } }
        )) {
            Button("OK") { syncViewModel.clearError() }
        } message: {
            Text(syncViewModel.error ?? "")
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        Section("PlayStation Network") {
            if authViewModel.isAuthenticated {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Connected")
                    Spacer()
                    Button("Disconnect") {
                        authViewModel.logout()
                    }
                    .foregroundStyle(.red)
                    .font(.caption)
                }
            } else {
                Button {
                    authViewModel.showLogin = true
                } label: {
                    Label("Sign in to PSN", systemImage: "person.badge.plus")
                }
            }
        }
    }

    // MARK: - Sync

    private var syncSection: some View {
        Section {
            // Sync optimisée
            Button {
                syncViewModel.syncGames(optimized: true)
            } label: {
                HStack {
                    Label("Smart sync", systemImage: "arrow.clockwise")
                        .foregroundStyle(syncViewModel.canSync ? .primary : .secondary)
                    Spacer()
                    if syncViewModel.isSyncing {
                        ProgressView()
                    }
                }
            }
            .disabled(!syncViewModel.canSync || syncViewModel.isSyncing)

            // Sync complète
            Button {
                syncViewModel.syncGames(optimized: false)
            } label: {
                HStack {
                    Label("Full sync", systemImage: "arrow.clockwise.circle")
                        .foregroundStyle(syncViewModel.canSync ? .orange : .secondary)
                    Spacer()
                    if syncViewModel.isSyncing {
                        ProgressView()
                    }
                }
            }
            .disabled(!syncViewModel.canSync || syncViewModel.isSyncing)

            if !syncViewModel.canSync, let next = syncViewModel.nextSyncFormatted {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.orange)
                    Text("Next sync available at \(next)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let lastSync = syncViewModel.lastSyncDate {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Last sync: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Sync")
        } footer: {
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Smart sync only updates games with new trophies or progress.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Full sync re-fetches all games and trophies. Takes longer.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Result

    private func resultSection(_ result: PSNSyncResult) -> some View {
        Section("Last sync result") {
            if result.added > 0 {
                Label("\(result.added) game\(result.added != 1 ? "s" : "") added", systemImage: "plus.circle")
                    .foregroundStyle(.green)
            }
            if result.updated > 0 {
                Label("\(result.updated) game\(result.updated != 1 ? "s" : "") updated", systemImage: "arrow.clockwise")
                    .foregroundStyle(.blue)
            }
            if result.skipped > 0 {
                Label("\(result.skipped) game\(result.skipped != 1 ? "s" : "") up to date", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            if result.hasErrors {
                Label("\(result.errors.count) error\(result.errors.count != 1 ? "s" : "")", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            }
        }
    }

    // MARK: - Tutorial

    private var tutorialSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 20) {
                Text("How to connect your PSN account")
                    .font(.headline)
                    .padding(.top, 4)

                tutorialStep(
                    number: 1,
                    icon: "person.badge.plus",
                    color: .blue,
                    title: "Sign in",
                    description: "Tap \"Sign in to PSN\" above. A PlayStation browser will open."
                )

                tutorialStep(
                    number: 2,
                    icon: "lock.open",
                    color: .orange,
                    title: "Log in to PlayStation",
                    description: "Enter your PlayStation Network email and password in the browser."
                )

                tutorialStep(
                    number: 3,
                    icon: "key.horizontal",
                    color: .green,
                    title: "Get your token",
                    description: "Once logged in, tap the \"Get token\" button in the top toolbar. This retrieves your NPSSO token automatically."
                )

                tutorialStep(
                    number: 4,
                    icon: "arrow.clockwise.circle",
                    color: .purple,
                    title: "Sync starts automatically",
                    description: "Once authenticated, your games and trophies will start syncing automatically. This may take a few minutes."
                )

                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "lock.shield")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 1)
                    Text("Your credentials are stored securely on your device and never shared.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        }
    }

    private func tutorialStep(number: Int, icon: String, color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("\(number).")
                        .font(.subheadline.bold())
                        .foregroundStyle(.secondary)
                    Text(title)
                        .font(.subheadline.bold())
                }
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}