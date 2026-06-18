//
//  ContentView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DataStore
    @Binding var navigateToGameId: UUID?

    var body: some View {
        HomeView(navigateToGameId: $navigateToGameId)
    }
}