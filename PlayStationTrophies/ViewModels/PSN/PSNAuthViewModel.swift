//
//  PSNAuthViewModel.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation
import Combine

@MainActor
final class PSNAuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var showLogin: Bool = false

    private let authService: PSNAuthService
    private var cancellables = Set<AnyCancellable>()

    init(authService: PSNAuthService) {
        self.authService = authService
        self.isAuthenticated = authService.isAuthenticated

        // Observe les changements de isAuthenticated dans authService
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authenticated in
                self?.isAuthenticated = authenticated
            }
            .store(in: &cancellables)
    }

    func onNpssoReceived(_ npsso: String) {
        isLoading = true
        Task {
            do {
                try await authService.exchangeNpssoForTokens(npsso: npsso)
                showLogin = false
            } catch {
                self.error = error.localizedDescription
            }
            isLoading = false
        }
    }

    func logout() {
        authService.logout()
    }

    func clearError() {
        error = nil
    }
}