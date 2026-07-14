//
//  GameDetailView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 16/04/2026.
//

import SwiftUI

struct GameDetailView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var syncViewModel: PSNSyncViewModel
    @EnvironmentObject private var psnContainer: PSNServiceContainer
    @EnvironmentObject private var profileStore: ProfileStore

    let gameId: UUID

    @State private var showCoverFullscreen = false
    @State private var collapsedExtensions: Set<String> = []
    @State private var revealedTrophies: Set<UUID> = []
    @State private var showHidden = false
    @State private var trophySort: TrophySort = .defaultOrder
    @State private var trophyFilter: TrophyFilter = .all
    @State private var showCompare = false

    init(game: Game) {
        self.gameId = game.id
    }

    private var isFiltered: Bool { trophyFilter != .all }
    private var isSorted: Bool { trophySort != .defaultOrder }
    private var isModified: Bool { isFiltered || isSorted }

    private func applyFilter(_ trophies: [Trophy]) -> [Trophy] {
        switch trophyFilter {
        case .all:        return trophies
        case .notEarned:  return trophies.filter { !$0.isUnlocked }
        case .inProgress: return trophies.filter { !$0.isUnlocked && ($0.progressRate ?? 0) > 0 }
        case .earned:     return trophies.filter { $0.isUnlocked }
        case .platinum:   return trophies.filter { $0.type == .platinum }
        case .gold:       return trophies.filter { $0.type == .gold }
        case .silver:     return trophies.filter { $0.type == .silver }
        case .bronze:     return trophies.filter { $0.type == .bronze }
        }
    }

    private func groupedTrophies(_ trophies: [Trophy]) -> [(header: String, trophies: [Trophy])] {
        switch trophySort {
        case .defaultOrder:
            return []

        case .notEarned:
            let earned = trophies.filter { $0.isUnlocked }
            let notEarned = trophies.filter { !$0.isUnlocked }
            var groups: [(String, [Trophy])] = []
            if !earned.isEmpty    { groups.append(("Earned: \(earned.count)", earned)) }
            if !notEarned.isEmpty { groups.append(("Not earned - with progress: \(notEarned.count)", notEarned)) }
            return groups

        case .rarity:
            let ultraRare = trophies.filter { ($0.earnedRate ?? 100) < 5 }
            let veryRare  = trophies.filter { let r = $0.earnedRate ?? 100; return r >= 5 && r < 15 }
            let rare      = trophies.filter { let r = $0.earnedRate ?? 100; return r >= 15 && r < 50 }
            let common    = trophies.filter { ($0.earnedRate ?? 100) >= 50 }
            var groups: [(String, [Trophy])] = []
            if !ultraRare.isEmpty { groups.append(("Ultra rare: \(ultraRare.count)", ultraRare)) }
            if !veryRare.isEmpty  { groups.append(("Very rare: \(veryRare.count)", veryRare)) }
            if !rare.isEmpty      { groups.append(("Rare: \(rare.count)", rare)) }
            if !common.isEmpty    { groups.append(("Common: \(common.count)", common)) }
            return groups

        case .earnedDate:
            let now = Date()
            let weekAgo  = Calendar.current.date(byAdding: .day, value: -7,  to: now)!
            let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: now)!

            let thisWeek  = trophies
                .filter { guard let d = $0.unlockedDate else { return false }; return d >= weekAgo }
                .sorted { $0.unlockedDate! > $1.unlockedDate! }
            let lastMonth = trophies
                .filter { guard let d = $0.unlockedDate else { return false }; return d >= monthAgo && d < weekAgo }
                .sorted { $0.unlockedDate! > $1.unlockedDate! }
            let older     = trophies
                .filter { guard let d = $0.unlockedDate else { return false }; return d < monthAgo }
                .sorted { $0.unlockedDate! > $1.unlockedDate! }
            let notEarned = trophies.filter { $0.unlockedDate == nil }

            var groups: [(String, [Trophy])] = []
            if !thisWeek.isEmpty  { groups.append(("Earned this week: \(thisWeek.count)", thisWeek)) }
            if !lastMonth.isEmpty { groups.append(("Earned in the last 30 days: \(lastMonth.count)", lastMonth)) }
            if !older.isEmpty     { groups.append(("Earned more than 30 days ago: \(older.count)", older)) }
            if !notEarned.isEmpty { groups.append(("Not earned: \(notEarned.count)", notEarned)) }
            return groups

        case .rank:
            let platinum = trophies.filter { $0.type == .platinum }
            let gold     = trophies.filter { $0.type == .gold }
            let silver   = trophies.filter { $0.type == .silver }
            let bronze   = trophies.filter { $0.type == .bronze }
            var groups: [(String, [Trophy])] = []
            if !platinum.isEmpty { groups.append(("Platinum: \(platinum.count)", platinum)) }
            if !gold.isEmpty     { groups.append(("Gold: \(gold.count)", gold)) }
            if !silver.isEmpty   { groups.append(("Silver: \(silver.count)", silver)) }
            if !bronze.isEmpty   { groups.append(("Bronze: \(bronze.count)", bronze)) }
            return groups
        }
    }

    var body: some View {
        Group {
            if let game = store.games.first(where: { $0.id == gameId }) {
                List {
                    statsSection(game: game)
                    trophiesSection(game: game)
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(game.title)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Section("Filter") {
                                ForEach(TrophyFilter.allCases, id: \.self) { filter in
                                    Button {
                                        withAnimation { trophyFilter = filter }
                                    } label: {
                                        HStack {
                                            Text(filter.rawValue)
                                            if trophyFilter == filter {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }

                            Section("Sort") {
                                ForEach(TrophySort.allCases, id: \.self) { sort in
                                    Button {
                                        withAnimation { trophySort = sort }
                                    } label: {
                                        HStack {
                                            Text(sort.rawValue)
                                            if trophySort == sort {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }

                            Section {
                                if game.trophies.contains(where: { $0.isHidden && !$0.isUnlocked }) {
                                    Button {
                                        withAnimation {
                                            showHidden.toggle()
                                            if !showHidden { revealedTrophies.removeAll() }
                                        }
                                    } label: {
                                        Label(
                                            showHidden ? "Hide hidden trophies" : "Reveal all hidden",
                                            systemImage: showHidden ? "eye.slash" : "eye"
                                        )
                                    }
                                }

                                Button {
                                    showCompare = true
                                } label: {
                                    Label("Compare with another player", systemImage: "person.2")
                                }

                                Button {
                                    var updated = game
                                    updated.isFavorite.toggle()
                                    store.updateGame(updated)
                                } label: {
                                    Label(
                                        game.isFavorite ? "Remove from favorites" : "Add to favorites",
                                        systemImage: game.isFavorite ? "star.slash" : "star"
                                    )
                                }

                                Button {
                                    syncViewModel.syncSingleGame(game)
                                } label: {
                                    Label("Sync this game", systemImage: "arrow.clockwise")
                                }
                                .disabled(syncViewModel.isSyncingGame)

                                if isModified {
                                    Button {
                                        withAnimation {
                                            trophyFilter = .all
                                            trophySort = .defaultOrder
                                        }
                                    } label: {
                                        Label("Reset filters & sort", systemImage: "xmark.circle")
                                    }
                                }
                            }
                        } label: {
                            if syncViewModel.isSyncingGame {
                                ProgressView().scaleEffect(0.8)
                            } else {
                                Image(systemName: isModified ? "ellipsis.circle.fill" : "ellipsis.circle")
                                    .foregroundStyle(isModified ? Color.blue : Color.primary)
                            }
                        }
                    }
                }
                .sheet(isPresented: $showCompare) {
                    CompareView(game: game)
                        .environmentObject(psnContainer)
                        .environmentObject(profileStore)
                }
            } else {
                ContentUnavailableView("Game not found", systemImage: "gamecontroller")
            }
        }
        .sheet(isPresented: $showCoverFullscreen) {
            if let game = store.games.first(where: { $0.id == gameId }) {
                ZStack(alignment: .topTrailing) {
                    Color.black.ignoresSafeArea()
                    if let url = game.coverURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            default:
                                gamePlaceholder(size: 300)
                            }
                        }
                    } else {
                        gamePlaceholder(size: 300)
                    }
                    Button { showCoverFullscreen = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { syncViewModel.error != nil },
            set: { if !$0 { syncViewModel.clearError() } }
        )) {
            Button("OK") { syncViewModel.clearError() }
        } message: {
            Text(syncViewModel.error ?? "")
        }
    }

    // MARK: - Stats

    private func statsSection(game: Game) -> some View {
        Section {
            VStack(spacing: 12) {
                CoverImageView(url: game.coverURL, size: CGSize(width: 160, height: 160))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onTapGesture { showCoverFullscreen = true }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        HStack(spacing: 6) {
                            ForEach(game.allPlatforms, id: \.self) { platform in
                                PlatformBadge(platform: platform)
                            }
                        }
                        Spacer()
                        HStack(spacing: 12) {
                            ForEach(TrophyType.displayOrder, id: \.self) { type in
                                let count = game.count(for: type)
                                if type == .platinum && count == 0 {
                                    EmptyView()
                                } else {
                                    HStack(spacing: 3) {
                                        Image(systemName: "trophy.fill")
                                            .foregroundStyle(type.color)
                                            .font(.caption)
                                        Text("\(count)")
                                            .font(.caption.bold())
                                    }
                                }
                            }
                        }
                    }

                    HStack(spacing: 4) {
                        Spacer()
                        Text("\(game.unlockedTrophies) unlocked")
                            .font(.caption.bold())
                        Text("•").foregroundStyle(.secondary)
                        Text("\(game.totalTrophies) total")
                            .font(.caption.bold())
                        Text("•").foregroundStyle(.secondary)
                        Text("\(game.totalPoints) pts")
                            .font(.caption.bold())
                        Text("•").foregroundStyle(.secondary)
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundStyle(.black)
                        Text("\(game.hiddenTrophiesCount)")
                            .font(.caption.bold())
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                ProgressView(value: game.completionPercentage, total: 100)
                    .tint(game.progressColor)
                    .scaleEffect(x: 1, y: 2)

                HStack {
                    Spacer()
                    Text(String(format: "%.0f%% completion", game.completionPercentage))
                        .font(.caption.bold())
                        .foregroundStyle(game.progressColor)
                    Spacer()
                }

                if game.extensions.count > 1 {
                    HStack(alignment: .top, spacing: 12) {
                        Text("DLCs")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .trailing)
                        HStack(spacing: 6) {
                            Image(systemName: "puzzlepiece.extension")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(game.extensions.count - 1) DLC\(game.extensions.count - 1 > 1 ? "s" : "")")
                                .font(.caption.bold())
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                if let first = game.firstTrophyDate {
                    if game.hasPlatinum, let platinum = game.platinumDate {
                        HStack(alignment: .top, spacing: 12) {
                            Text("Platinum")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 80, alignment: .trailing)
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .font(.caption)
                                    .foregroundStyle(.cyan)
                                Text(game.completionDuration(from: first, to: platinum))
                                    .font(.caption.bold())
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)

                        if game.extensions.count > 1,
                           game.completionPercentage == 100,
                           let last = game.lastTrophyDate,
                           last > platinum {
                            HStack(alignment: .top, spacing: 12) {
                                Text("100%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                    Text(game.completionDuration(from: first, to: last))
                                        .font(.caption.bold())
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    } else if game.completionPercentage == 100, let last = game.lastTrophyDate {
                        HStack(alignment: .top, spacing: 12) {
                            Text("100%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 80, alignment: .trailing)
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                Text(game.completionDuration(from: first, to: last))
                                    .font(.caption.bold())
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }

                if game.formattedPlayDuration != nil {
                    VStack(spacing: 4) {
                        Divider()

                        if let duration = game.formattedPlayDuration {
                            HStack(alignment: .top, spacing: 12) {
                                Text("Play time")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                    Text(duration)
                                        .font(.caption.bold())
                                }
                                Spacer()
                            }
                        }

                        if let count = game.playCount {
                            HStack(alignment: .top, spacing: 12) {
                                Text("Sessions")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                                HStack(spacing: 6) {
                                    Image(systemName: "gamecontroller.fill")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                    Text("\(count) session\(count > 1 ? "s" : "")")
                                        .font(.caption.bold())
                                }
                                Spacer()
                            }
                        }

                        if let avg = game.averageSessionDuration {
                            HStack(alignment: .top, spacing: 12) {
                                Text("Avg. session")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                                HStack(spacing: 6) {
                                    Image(systemName: "timer")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                    Text(avg)
                                        .font(.caption.bold())
                                }
                                Spacer()
                            }
                        }

                        if let first = game.firstPlayedDate {
                            HStack(alignment: .top, spacing: 12) {
                                Text("First played")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                    Text(first.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption.bold())
                                }
                                Spacer()
                            }
                        }

                        if let last = game.lastPlayedDate {
                            HStack(alignment: .top, spacing: 12) {
                                Text("Last played")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                                HStack(spacing: 6) {
                                    Image(systemName: "calendar.badge.clock")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                    Text(last.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption.bold())
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Trophies

    @ViewBuilder
    private func trophiesSection(game: Game) -> some View {
        if game.trophies.isEmpty {
            Section("Trophies") {
                ContentUnavailableView(
                    "No trophies yet",
                    systemImage: "trophy",
                    description: Text("Sync your PSN account to load trophies")
                )
            }
        } else if trophySort == .defaultOrder {
            let hasContent = game.extensions.contains { ext in
                !applyFilter(game.trophies(for: ext.name)).isEmpty
            }

            if !hasContent {
                Section("Trophies") {
                    ContentUnavailableView(
                        "No trophies match this filter",
                        systemImage: "line.3.horizontal.decrease.circle",
                        description: Text("Try changing or resetting the filter")
                    )
                }
            } else {
                if trophyFilter == .all, let rarest = game.trophies
                    .filter({ $0.isUnlocked })
                    .min(by: { ($0.earnedRate ?? 100) < ($1.earnedRate ?? 100) }) {
                    Section("Rarest trophy earned") {
                        TrophyRowView(
                            trophy: rarest,
                            isRevealed: showHidden || revealedTrophies.contains(rarest.id)
                        ) {
                            withAnimation { _ = revealedTrophies.insert(rarest.id) }
                        }
                    }
                }

                ForEach(game.extensions) { ext in
                    let trophies = applyFilter(game.trophies(for: ext.name))
                    if !trophies.isEmpty {
                        extensionGroup(ext: ext, trophies: trophies, game: game)
                    }
                }
            }
        } else {
            let allTrophies = applyFilter(game.extensions.flatMap { game.trophies(for: $0.name) })
            let groups = groupedTrophies(allTrophies)

            if groups.isEmpty {
                Section("Trophies") {
                    ContentUnavailableView(
                        "No trophies match this filter",
                        systemImage: "line.3.horizontal.decrease.circle",
                        description: Text("Try changing or resetting the filter")
                    )
                }
            } else {
                ForEach(groups, id: \.header) { group in
                    Section(group.header) {
                        ForEach(group.trophies) { trophy in
                            TrophyRowView(
                                trophy: trophy,
                                isRevealed: showHidden || revealedTrophies.contains(trophy.id)
                            ) {
                                withAnimation { _ = revealedTrophies.insert(trophy.id) }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Extension group

    @ViewBuilder
    private func extensionGroup(ext: GameExtension, trophies: [Trophy], game: Game) -> some View {
        let unlockedCount = trophies.filter(\.isUnlocked).count
        let totalCount = trophies.count

        Section {
            if !collapsedExtensions.contains(ext.name) {
                ForEach(trophies) { trophy in
                    TrophyRowView(
                        trophy: trophy,
                        isRevealed: showHidden || revealedTrophies.contains(trophy.id)
                    ) {
                        withAnimation { _ = revealedTrophies.insert(trophy.id) }
                    }
                }
            }
        } header: {
            HStack(alignment: .top, spacing: 10) {
                if let iconUrlString = ext.iconUrl,
                   let iconUrl = URL(string: iconUrlString) {
                    CoverImageView(url: iconUrl, size: CGSize(width: 40, height: 40))
                } else if game.coverURL != nil {
                    CoverImageView(url: game.coverURL, size: CGSize(width: 40, height: 40))
                } else {
                    groupImageFallback
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(ext.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Text("\(unlockedCount) of \(totalCount) trophies")
                            .font(.caption.bold())
                            .foregroundStyle(game.completionColor(for: ext.name))
                        Text("•").font(.caption).foregroundStyle(.secondary)
                        ForEach(TrophyType.displayOrder, id: \.self) { type in
                            let count = trophies.filter { $0.type == type }.count
                            if count > 0 {
                                HStack(spacing: 2) {
                                    Image(systemName: "trophy.fill")
                                        .font(.caption2)
                                        .foregroundStyle(type.color)
                                    Text("\(count)")
                                        .font(.caption2.bold())
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: collapsedExtensions.contains(ext.name) ? "chevron.down" : "chevron.up")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    if collapsedExtensions.contains(ext.name) {
                        collapsedExtensions.remove(ext.name)
                    } else {
                        collapsedExtensions.insert(ext.name)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var groupImageFallback: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "puzzlepiece.extension")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            .frame(width: 40, height: 40)
    }

    private func gamePlaceholder(size: CGFloat) -> some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "gamecontroller")
                .font(.system(size: size / 3))
                .foregroundStyle(.secondary)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}