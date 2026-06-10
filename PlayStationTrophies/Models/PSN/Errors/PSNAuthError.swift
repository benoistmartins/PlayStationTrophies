//
//  PSNAuthError.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

enum PSNAuthError: LocalizedError {
    case npssoNotFound
    case accessCodeFailed
    case tokenExchangeFailed
    case refreshFailed
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .npssoNotFound:       return "Could not retrieve NPSSO token"
        case .accessCodeFailed:    return "Could not exchange NPSSO for access code"
        case .tokenExchangeFailed: return "Could not exchange access code for tokens"
        case .refreshFailed:       return "Could not refresh access token"
        case .notAuthenticated:    return "Not authenticated — please sign in"
        }
    }
}
