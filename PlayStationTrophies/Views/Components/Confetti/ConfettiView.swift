//
//  ConfettiView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 19/06/2026.
//

import SwiftUI

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    @State private var animate = false

    private let colors: [Color] = [.cyan, .yellow, .green, .pink, .orange, .purple, .blue]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.4)
                        .rotationEffect(.degrees(animate ? piece.rotation : 0))
                        .position(
                            x: piece.xPosition * geo.size.width,
                            y: animate ? geo.size.height + 50 : -50
                        )
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: animate
                        )
                }
            }
            .onAppear {
                generatePieces(width: geo.size.width)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    animate = true
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func generatePieces(width: CGFloat) {
        pieces = (0..<20).map { _ in
            ConfettiPiece(
                color: colors.randomElement() ?? .cyan,
                xPosition: CGFloat.random(in: 0...1),
                delay: Double.random(in: 0...0.3),
                duration: Double.random(in: 1.8...2.8),
                rotation: Double.random(in: 180...720),
                size: CGFloat.random(in: 6...12)
            )
        }
    }
}