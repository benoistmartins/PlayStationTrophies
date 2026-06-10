//
//  LaunchScreenView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 17/04/2026.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 24) {
                Image("PlayStationTrophies")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 26))

                Text("PlayStation Trophies")
                    .font(.title2.bold())
                    .foregroundStyle(.black)

                ProgressView()
                    .tint(.black)
            }
        }
    }
}
