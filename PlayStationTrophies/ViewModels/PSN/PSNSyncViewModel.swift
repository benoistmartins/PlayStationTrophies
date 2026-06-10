//
//  PSNSyncViewModel.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation
import Combine

final class PSNSyncViewModel: ObservableObject {
    @Published var isSyncing = false
    @Published var isSyncingGame = false
    @Published var syncResult: PSNSyncResult? = nil
    @Published var error: String? = nil
    @Published var lastSyncDate: Date? = nil

    private let syncService: PSNSyncService
    private let cooldown: TimeInterval = 3 * 60 * 60
    private let lastSyncKey = "psn_last_sync_date"

    init(syncService: PSNSyncService) {
        self.syncService = syncService
        if let saved = UserDefaults.standard.object(forKey: lastSyncKey) as? Date {
            lastSyncDate = saved
        }
    }

    var canSync: Bool {
        guard let lastSync = lastSyncDate else { return true }
        return Date().timeIntervalSince(lastSync) >= cooldown
    }

    var nextSyncFormatted: String? {
        guard let lastSync = lastSyncDate, !canSync else { return nil }
        let next = lastSync.addingTimeInterval(cooldown)
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeStyle = .short
        if calendar.isDateInToday(next) {
            formatter.dateStyle = .none
        } else {
            formatter.dateStyle = .medium
        }
        return formatter.string(from: next)
    }

    func syncGames(optimized: Bool = true) {
        guard !isSyncing, canSync else { return }
        isSyncing = true
        syncResult = nil

        Task {
            do {
                let result = try await syncService.syncAll(optimized: optimized)
                await MainActor.run {
                    syncResult = result
                    isSyncing = false
                    lastSyncDate = Date()
                    UserDefaults.standard.set(lastSyncDate, forKey: lastSyncKey)
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    isSyncing = false
                }
            }
        }
    }

    func syncSingleGame(_ game: Game) {
        guard !isSyncingGame else { return }
        guard let communicationId = game.psnCommunicationId,
              let serviceName = game.psnServiceName else { return }
        isSyncingGame = true

        Task {
            do {
                try await syncService.syncSingleGame(
                    communicationId: communicationId,
                    serviceName: serviceName
                )
                await MainActor.run {
                    isSyncingGame = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    isSyncingGame = false
                }
            }
        }
    }

    func clearError() {
        error = nil
    }
}