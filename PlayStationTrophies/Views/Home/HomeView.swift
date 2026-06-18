//
//  HomeView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var profileStore: ProfileStore
    @EnvironmentObject private var authViewModel: PSNAuthViewModel
    @EnvironmentObject private var syncViewModel: PSNSyncViewModel
    @Binding var navigateToGameId: UUID?
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showAdvancedSearch = false
    @State private var showFavoritesOnly = false
    @State private var showSync = false
    @State private var sortOption = SortOption(field: .lastUpdate, order: .descending)
    @State private var searchText = ""
    @State private var activeFilter = SearchFilter()
    @State private var selectedFilter: GameFilter = .all

    private var filteredByStatus: [Game] {
        switch selectedFilter {
        case .all:       return store.games
        case .playing:   return store.games.filter { $0.effectiveStatus == .playing }
        case .completed: return store.games.filter { $0.effectiveStatus == .completed }
        }
    }

    private var sortedGames: [Game] {
        let filtered = filteredByStatus
            .filter { showFavoritesOnly ? $0.isFavorite : true }
            .filter { searchText.isEmpty ? true : $0.title.localizedCaseInsensitiveContains(searchText) }
            .filter { applyFilter($0) }

        return filtered.sorted { lhs, rhs in
            switch sortOption.field {
            case .lastUpdate:
                return sortOption.order == .ascending ? lhs.lastUpdate < rhs.lastUpdate : lhs.lastUpdate > rhs.lastUpdate
            case .name:
                let result = lhs.title.localizedCompare(rhs.title) == .orderedAscending
                return sortOption.order == .ascending ? result : !result
            case .completion:
                return sortOption.order == .ascending
                    ? lhs.completionPercentage < rhs.completionPercentage
                    : lhs.completionPercentage > rhs.completionPercentage
            case .trophyCount:
                return sortOption.order == .ascending
                    ? lhs.totalTrophies < rhs.totalTrophies
                    : lhs.totalTrophies > rhs.totalTrophies
            }
        }
    }

    private func applyFilter(_ game: Game) -> Bool {
        if !activeFilter.name.isEmpty {
            guard game.title.localizedCaseInsensitiveContains(activeFilter.name) else { return false }
        }
        if !activeFilter.platforms.isEmpty {
            guard !activeFilter.platforms.isDisjoint(with: Set(game.allPlatforms)) else { return false }
        }
        switch activeFilter.platinumFilter {
        case .all: break
        case .withPlatinum: guard game.trophies.contains(where: { $0.type == .platinum }) else { return false }
        case .withoutPlatinum: guard !game.trophies.contains(where: { $0.type == .platinum }) else { return false }
        }
        switch activeFilter.progressionFilter {
        case .all: break
        case .completed: guard game.completionPercentage == 100 else { return false }
        case .notCompleted: guard game.completionPercentage < 100 else { return false }
        case .notCompletedOrPlatinum: guard game.completionPercentage < 100 || !game.hasPlatinum else { return false }
        case .platinumed: guard game.hasPlatinum else { return false }
        case .platinumedNotCompleted: guard game.hasPlatinum && game.completionPercentage < 100 else { return false }
        }
        return true
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.games.isEmpty {
                    emptyStateView
                } else if filteredByStatus.isEmpty {
                    VStack(spacing: 0) {
                        pickerView
                        ContentUnavailableView(
                            emptyTitle,
                            systemImage: emptyIcon,
                            description: Text(emptyDescription)
                        )
                    }
                } else if sortedGames.isEmpty && showFavoritesOnly {
                    VStack(spacing: 0) {
                        pickerView
                        ContentUnavailableView(
                            "No favorites yet",
                            systemImage: "star",
                            description: Text("Tap ★ on a game to add it to your favorites")
                        )
                    }
                } else if sortedGames.isEmpty {
                    VStack(spacing: 0) {
                        pickerView
                        ContentUnavailableView.search(text: searchText)
                    }
                } else {
                    gameList
                }
            }
            .navigationTitle("My Trophies")
            .searchable(text: $searchText, prompt: "Search a game...")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            showProfile = true
                        } label: {
                            Label("Profile", systemImage: "person")
                        }
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                        Button {
                            showAdvancedSearch = true
                        } label: {
                            Label("Advanced search", systemImage: "magnifyingglass")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFavoritesOnly.toggle()
                    } label: {
                        Image(systemName: showFavoritesOnly ? "star.fill" : "star")
                            .foregroundStyle(showFavoritesOnly ? .yellow : .primary)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(SortField.allCases, id: \.self) { field in
                            Button {
                                if sortOption.field == field {
                                    sortOption.order.toggle()
                                } else {
                                    sortOption.field = field
                                    sortOption.order = .descending
                                }
                            } label: {
                                HStack {
                                    Text(field.rawValue)
                                    Image(systemName: sortOption.field == field
                                          ? sortOption.order.icon
                                          : "chevron.up.chevron.down")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSync = true
                    } label: {
                        if syncViewModel.isSyncing {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Image("playstation")
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                        }
                    }
                }
            }
            .sheet(isPresented: $showSync) {
                PSNSyncView()
                    .environmentObject(authViewModel)
                    .environmentObject(syncViewModel)
            }
            .sheet(isPresented: $showProfile) {
                NavigationStack {
                    ProfileView()
                        .environmentObject(store)
                        .environmentObject(profileStore)
                        .environmentObject(authViewModel)
                        .environmentObject(syncViewModel)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(store)
                    .environmentObject(authViewModel)
                    .environmentObject(syncViewModel)
            }
            .sheet(isPresented: $showAdvancedSearch) {
                AdvancedSearchView(filter: $activeFilter)
            }
            .onChange(of: navigateToGameId) { _, gameId in
                if gameId != nil {
                    showSync = false
                    showProfile = false
                    showSettings = false
                    showAdvancedSearch = false
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { navigateToGameId != nil },
                set: { if !$0 { navigateToGameId = nil } }
            )) {
                if let gameId = navigateToGameId,
                   let game = store.games.first(where: { $0.id == gameId }) {
                    GameDetailView(game: game)
                        .environmentObject(syncViewModel)
                }
            }
        }
    }

    // MARK: - Subviews

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image("playstation")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 60, height: 60)
            Text("No games yet")
                .font(.title2.bold())
            Text("Sync your PSN account to load your games")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showSync = true
            } label: {
                Text("Sync PSN")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }

    private var pickerView: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(GameFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var emptyTitle: String {
        switch selectedFilter {
        case .all:       return "No games yet"
        case .playing:   return "No games in progress"
        case .completed: return "No completed games"
        }
    }

    private var emptyIcon: String {
        switch selectedFilter {
        case .all:       return "gamecontroller"
        case .playing:   return "play.circle"
        case .completed: return "checkmark.circle"
        }
    }

    private var emptyDescription: String {
        switch selectedFilter {
        case .all:       return "Sync your PSN account to load your games"
        case .playing:   return "Unlock a trophy to start playing"
        case .completed: return "Reach 100% on a game to complete it"
        }
    }

    private var statusPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(GameFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }

    private var gameList: some View {
        List {
            Section {
                statusPicker
            }
            .listRowBackground(Color.clear)

            Section {
                RecentTrophiesView()
                    .environmentObject(store)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            if !activeFilter.isEmpty {
                ActiveFiltersBar(filter: $activeFilter)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color(.systemGray6))
                    .listRowSeparator(.hidden)
            }

            ForEach(sortedGames) { game in
                NavigationLink(destination:
                    GameDetailView(game: game)
                        .environmentObject(syncViewModel)
                ) {
                    GameRowView(gameId: game.id)
                        .environmentObject(store)
                }
            }
        }
        .refreshable {
            guard syncViewModel.canSync else { return }
            await withCheckedContinuation { continuation in
                syncViewModel.syncGames(optimized: true)
                Task {
                    while syncViewModel.isSyncing {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                    }
                    continuation.resume()
                }
            }
        }
    }
}
