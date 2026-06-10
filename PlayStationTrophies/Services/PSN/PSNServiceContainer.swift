//
//  PSNServiceContainer.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation
import Combine

final class PSNServiceContainer: ObservableObject {
    let authService: PSNAuthService
    let apiService: PSNAPIService
    let authViewModel: PSNAuthViewModel
    let syncViewModel: PSNSyncViewModel

    init(store: DataStore, profileStore: ProfileStore) {
        let auth = PSNAuthService()
        let api = PSNAPIService(authService: auth)
        let sync = PSNSyncService(apiService: api, store: store, profileStore: profileStore)
        self.authService = auth
        self.apiService = api
        self.authViewModel = PSNAuthViewModel(authService: auth)
        self.syncViewModel = PSNSyncViewModel(syncService: sync)
    }
}