//
//  ConfettiPiece.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 19/06/2026.
//

import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let xPosition: CGFloat
    let delay: Double
    let duration: Double
    let rotation: Double
    let size: CGFloat
}