//
//  ActivityControllerView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 25/06/2026.
//

import SwiftUI
import UIKit

struct ActivityControllerView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList,
            .openInIBooks,
            .postToFlickr,
            .postToVimeo,
            .postToWeibo,
            .postToTencentWeibo,
            .markupAsPDF,
            .print
        ]

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
