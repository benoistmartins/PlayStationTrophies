//
//  CoverImageView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import SwiftUI

struct CoverImageView: View {
    let url: URL?
    let size: CGSize

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholder.overlay {
                            ProgressView()
                        }
                    case .success(let image):
                        ZStack {
                            Color(.systemGray5)
                            image
                                .resizable()
                                .scaledToFit()
                        }
                    case .failure:
                        placeholder.overlay {
                            Image(systemName: "photo.badge.exclamationmark")
                                .foregroundStyle(.secondary)
                        }
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "gamecontroller")
                    .foregroundStyle(.secondary)
            }
    }
}
