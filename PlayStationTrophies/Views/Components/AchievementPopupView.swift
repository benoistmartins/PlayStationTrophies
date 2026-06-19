//
//  AchievementPopupView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 18/06/2026.
//

import SwiftUI

struct AchievementPopupView: View {
    let achievement: AchievementUnlock
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0

    private var title: String {
        switch achievement.type {
        case .platinum:        return "Platinum unlocked! 🏆"
        case .hundredPercent:  return "100% completed! ✅"
        }
    }

    private var subtitle: String {
        switch achievement.type {
        case .platinum:        return "You platinumed"
        case .hundredPercent:  return "You completed 100% of"
        }
    }

    private var accentColor: Color {
        switch achievement.type {
        case .platinum:        return .cyan
        case .hundredPercent:  return .green
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            ConfettiView()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                CoverImageView(
                    url: achievement.game.coverURL,
                    size: CGSize(width: 120, height: 120)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: accentColor.opacity(0.6), radius: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(accentColor, lineWidth: 2)
                )

                VStack(spacing: 8) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(accentColor)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(achievement.game.title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }

                Text("Congratulations! 🎉")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    dismiss()
                } label: {
                    Text("Thanks!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(radius: 30)
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 0.8
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}