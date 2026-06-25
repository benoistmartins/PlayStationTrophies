//
//  ShareSheetView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 25/06/2026.
//

import SwiftUI

struct ShareSheetView: View {
    let image: UIImage
    let gameName: String
    @Environment(\.dismiss) private var dismiss
    @State private var showActivityController = false

    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 36, height: 4)
                .padding(.top, 12)

            Text("Share your achievement")
                .font(.headline)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)
                .padding(.horizontal, 32)

            Button {
                showActivityController = true
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)

            Button {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                dismiss()
            } label: {
                Label("Save to Photos", systemImage: "photo.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .sheet(isPresented: $showActivityController) {
            ActivityControllerView(image: image)
        }
    }
}