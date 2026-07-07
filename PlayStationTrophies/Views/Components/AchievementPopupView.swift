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
    @State private var coverImage: UIImage? = nil
    @State private var renderedImage: UIImage? = nil
    @State private var showShareSheet = false

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

    private var durationLabel: (value: String, label: String)? {
        let game = achievement.game
        if let duration = game.formattedPlayDuration {
            return (duration, "Play time")
        }
        guard let first = game.firstTrophyDate else { return nil }
        switch achievement.type {
        case .platinum:
            guard let platinum = game.platinumDate else { return nil }
            return (game.completionDuration(from: first, to: platinum), "Completion time")
        case .hundredPercent:
            guard let last = game.lastTrophyDate else { return nil }
            return (game.completionDuration(from: first, to: last), "Completion time")
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

                    if let duration = durationLabel {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(duration.label): \(duration.value)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Text("Congratulations! 🎉")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 10) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(accentColor.opacity(0.15))
                            .foregroundStyle(accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(accentColor, lineWidth: 1)
                            )
                    }
                    .disabled(renderedImage == nil)
                    .opacity(renderedImage == nil ? 0.5 : 1)

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
            Task { await loadAndRender() }
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = renderedImage {
                ShareSheetView(image: image, gameName: achievement.game.title)
                    .presentationDetents([.medium, .large])
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

    private func loadAndRender() async {
        if let url = achievement.game.coverURL {
            coverImage = await downloadImage(from: url)
        }
        renderCard()
    }

    private func downloadImage(from url: URL) async -> UIImage? {
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        return UIImage(data: data)
    }

    @MainActor
    private func renderCard() {
        let card = ShareCardView(achievement: achievement, coverImage: coverImage)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3.0
        renderedImage = renderer.uiImage
    }
}