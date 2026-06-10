//
//  AnyShape.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 27/04/2026.
//

import SwiftUI

struct AnyShape: Shape {
    private let base: @Sendable (CGRect) -> Path

    init<S: Shape>(_ shape: S) {
        base = { rect in shape.path(in: rect) }
    }

    func path(in rect: CGRect) -> Path {
        base(rect)
    }
}
