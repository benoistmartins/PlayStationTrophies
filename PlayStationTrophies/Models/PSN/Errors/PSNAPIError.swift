//
//  PSNAPIError.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 11/05/2026.
//

import Foundation

enum PSNAPIError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case decodingFailed
    case rateLimited

    var errorDescription: String? {
        switch self {
        case .invalidResponse:    return "Invalid response from PlayStation Network"
        case .httpError(let code): return "HTTP error \(code)"
        case .decodingFailed:     return "Could not parse PlayStation Network response"
        case .rateLimited:        return "Too many requests — please wait before retrying"
        }
    }
}
