//
//  PlatformBadge.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 22/04/2026.
//

import SwiftUI

struct PlatformBadge: View {
    let platform: Platform

    var body: some View {
        Text(platform.badgeLabel)
            .font(.caption.bold())
            .foregroundStyle(platform.textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(platform.color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}