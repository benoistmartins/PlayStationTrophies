//
//  ActiveFiltersBar.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 20/04/2026.
//

import SwiftUI

struct ActiveFiltersBar: View {
    @Binding var filter: SearchFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    filter = SearchFilter()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                        Text("Clear all")
                    }
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color.red.opacity(0.15))
                    .foregroundStyle(.red)
                    .clipShape(Capsule())
                }

                if !filter.name.isEmpty {
                    filterChip(label: "Name: \(filter.name)") { filter.name = "" }
                }
                ForEach(Array(filter.platforms), id: \.self) { platform in
                    filterChip(label: platform.rawValue) { filter.platforms.remove(platform) }
                }
                if filter.platinumFilter != .all {
                    filterChip(label: filter.platinumFilter.rawValue) {
                        filter.platinumFilter = .all
                    }
                }
                if filter.progressionFilter != .all {
                    filterChip(label: filter.progressionFilter.rawValue) {
                        filter.progressionFilter = .all
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
        .background(Color(.systemGray6))
    }
}

private extension ActiveFiltersBar {
    func filterChip(label: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(label)
            Button { onRemove() } label: {
                Image(systemName: "xmark")
                    .font(.caption2.bold())
            }
        }
        .font(.caption.bold())
        .padding(.horizontal, 10)
        .padding(.vertical, 3)
        .background(Color.blue.opacity(0.15))
        .foregroundStyle(.blue)
        .clipShape(Capsule())
    }
}