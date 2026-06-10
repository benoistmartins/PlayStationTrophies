//
//  ProfileStore.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 18/04/2026.
//

import Foundation
import Combine

final class ProfileStore: ObservableObject {
    @Published var profile: PlayerProfile = PlayerProfile()

    private let saveURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("profile.json")
    }()

    init() {
        load()
    }

    func save() {
        if let data = try? JSONEncoder().encode(profile) {
            try? data.write(to: saveURL, options: .atomic)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode(PlayerProfile.self, from: data) else { return }
        profile = decoded
    }
}