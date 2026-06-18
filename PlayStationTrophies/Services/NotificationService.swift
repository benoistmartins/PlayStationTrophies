//
//  NotificationService.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 18/06/2026.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    // MARK: - Permissions

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("❌ NotificationService | Authorization error: \(error)")
            return false
        }
    }

    var isAuthorized: Bool {
        get async {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            return settings.authorizationStatus == .authorized
        }
    }

    // MARK: - New DLC

    func sendNewDLCNotification(dlcName: String, gameName: String, communicationId: String) async {
        guard await isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "New DLC available — \(gameName)"
        content.body = "\(dlcName) is now available. Go hunting trophies! 🏆"
        content.sound = .default
        content.userInfo = ["communicationId": communicationId]

        let request = UNNotificationRequest(
            identifier: "dlc-\(gameName)-\(dlcName)-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("❌ NotificationService | Send error: \(error)")
        }
    }
}