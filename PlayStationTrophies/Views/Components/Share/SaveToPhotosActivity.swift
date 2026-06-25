//
//  SaveToPhotosActivity.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 25/06/2026.
//

import SwiftUI
import UIKit

final class SaveToPhotosActivity: UIActivity {
    private let image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    override var activityTitle: String? { "Save to Photos" }
    override var activityImage: UIImage? { UIImage(systemName: "photo.badge.plus") }
    override var activityType: UIActivity.ActivityType? {
        UIActivity.ActivityType("com.playstationtrophies.saveToPhotos")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool { true }

    override func perform() {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        activityDidFinish(error == nil)
    }
}