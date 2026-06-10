//
//  UUID+Identifiable.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 01/05/2026.
//

import Foundation

extension UUID: @retroactive Identifiable {
    public var id: UUID { self }
}
