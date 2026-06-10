//
//  StatBadge.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 17/04/2026.
//

import SwiftUI

struct StatBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
