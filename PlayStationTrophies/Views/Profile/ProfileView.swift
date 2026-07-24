//
//  ProfileView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 18/04/2026.
//

import SwiftUI
import Charts

struct ProfileView: View {
    @EnvironmentObject private var store: DataStore
    @EnvironmentObject private var profileStore: ProfileStore
    @State private var selectedYear: Int? = nil
    @State private var selectedChartYear: Int? = nil
    @State private var selectedPlatform: Platform? = nil
    @State private var selectedChartMonth: String? = nil
    @State private var platinumSortOption: PlatinumSortOption = .mostRecent

    private var level: PlayerLevel { store.playerLevel }
    private var totalPoints: Int { store.totalPointsAllGames }

    private var currentPlatform: Platform {
        selectedPlatform ?? store.usedPlatforms.first(where: { $0 == .ps5 })
            ?? store.usedPlatforms.first(where: { $0 == .ps4 })
            ?? store.usedPlatforms.first ?? .ps5
    }

    var body: some View {
        List {
            levelSection
            sectionDivider(icon: "chart.bar.fill", title: "Overview", color: .blue)
            globalStatsSection
            sectionDivider(icon: "trophy.fill", title: "Platinums this year", color: .cyan)
            platinumsThisYearSection
            sectionDivider(icon: "trophy.fill", title: "Trophy breakdown", color: .yellow)
            trophyBreakdownSection
            sectionDivider(icon: "calendar", title: "Stats by year", color: .orange)
            yearStatsSection
            sectionDivider(icon: "waveform.path.ecg", title: "Activity", color: .green)
            monthlyChartSection
            sectionDivider(icon: "chart.pie.fill", title: "Activity breakdown", color: .teal)
            activityBreakdownSection
            if store.usedPlatforms.count > 1 {
                sectionDivider(icon: "gamecontroller.fill", title: "Stats by platform", color: .purple)
                platformStatsSection
            }
        }
        .listSectionSpacing(0)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Section divider

    private func sectionDivider(icon: String, title: String, color: Color) -> some View {
        Section {
            EmptyView()
        } header: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.white)
                    .font(.caption.bold())
                    .frame(width: 22, height: 22)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .textCase(nil)
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - Level

    private var levelSection: some View {
        Section {
            VStack(spacing: 16) {
                AsyncImage(url: profileStore.profile.avatarURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    default:
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray5))
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 80, height: 80)
                    }
                }

                Text(profileStore.profile.username)
                    .font(.title2.bold())

                Text("Level \(level.level)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if level.isMaxLevel {
                    Text("Max level reached 🏆")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 6) {
                        ProgressView(value: level.progress(currentPoints: totalPoints))
                            .tint(.blue)
                            .scaleEffect(x: 1, y: 2)

                        Text(String(format: "%.0f%%", level.progress(currentPoints: totalPoints) * 100))
                            .font(.caption.bold())
                            .foregroundStyle(.blue)

                        HStack {
                            Text("\(totalPoints) pts")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            if let next = level.nextLevelPoints {
                                Text("\(next) pts")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Global stats

    private var globalStatsSection: some View {
        Section {
            HStack {
                StatBadge(value: "\(store.games.count)", label: "Games")
                Spacer()
                StatBadge(value: "\(store.games.filter { $0.effectiveStatus == .playing }.count)", label: "Playing")
                Spacer()
                StatBadge(value: "\(store.completedGames)", label: "Completed")
                Spacer()
                StatBadge(value: "\(store.totalPlatinums)", label: "Platinums")
            }
            .padding(.vertical, 8)

            HStack {
                StatBadge(value: "\(store.totalUnlockedTrophies)", label: "Trophies")
                Spacer()
                StatBadge(value: "\(totalPoints)", label: "Points")
                Spacer()
                StatBadge(value: String(format: "%.2f%%", store.globalCompletionPercentage), label: "Completion")
                Spacer()
                StatBadge(value: "\(store.unearnedTrophies)", label: "Unearned")
            }
            .padding(.vertical, 8)

            if let best = store.mostActiveMonth {
                HStack {
                    Text("Most active month")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(monthName(best.month)) \(String(best.year)) · \(best.count) trophies")
                        .font(.body.bold())
                }
            }
        }
    }

    // MARK: - Platinums this year

    private var platinumsThisYearSection: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        let platinumedGames = sortedPlatinumGames(store.gamesPlatinumed(in: currentYear))

        return Section {
            HStack {
                StatBadge(value: "\(platinumedGames.count)", label: "Platinums in \(String(currentYear))")
                Spacer()
                Menu {
                    ForEach(PlatinumSortOption.allCases, id: \.self) { option in
                        Button {
                            platinumSortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if platinumSortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)

            if platinumedGames.isEmpty {
                Text("No platinum yet this year")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(platinumedGames) { game in
                    HStack(spacing: 12) {
                        CoverImageView(url: game.coverURL, size: CGSize(width: 36, height: 36))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        Text(game.title)
                            .font(.body)
                        Spacer()
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.cyan)
                    }
                }
            }
        }
    }

    private func sortedPlatinumGames(_ games: [Game]) -> [Game] {
        switch platinumSortOption {
        case .mostRecent:
            return games.sorted { ($0.platinumDate ?? .distantPast) > ($1.platinumDate ?? .distantPast) }
        case .oldest:
            return games.sorted { ($0.platinumDate ?? .distantPast) < ($1.platinumDate ?? .distantPast) }
        case .alphabetical:
            return games.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        }
    }

    // MARK: - Trophy breakdown

    private var trophyBreakdownSection: some View {
        Section {
            ForEach(TrophyType.displayOrder, id: \.self) { type in
                let count = store.games.reduce(0) { total, game in
                    total + game.trophies.filter { $0.type == type && $0.isUnlocked }.count
                }
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(type.color)
                    Text(type.rawValue)
                    Spacer()
                    Text("\(count)")
                        .font(.body.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Year stats

    @ViewBuilder
    private var yearStatsSection: some View {
        let years = store.availableYears
        if !years.isEmpty {
            Section {
                Picker("Year", selection: Binding(
                    get: { selectedYear ?? years.first ?? Calendar.current.component(.year, from: Date()) },
                    set: { selectedYear = $0 }
                )) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .onAppear {
                    if selectedYear == nil { selectedYear = years.first }
                }

                let year = selectedYear ?? years.first ?? Calendar.current.component(.year, from: Date())
                let trophies = store.trophiesUnlocked(in: year)

                HStack {
                    StatBadge(value: "\(trophies.count)", label: "Trophies")
                    Spacer()
                    StatBadge(value: "\(store.pointsEarned(in: year))", label: "Points")
                    Spacer()
                    StatBadge(value: "\(store.platinumsEarned(in: year))", label: "Platinums")
                    Spacer()
                    StatBadge(value: "\(store.gamesStarted(in: year))", label: "Games")
                }
                .padding(.vertical, 8)

                ForEach(TrophyType.displayOrder, id: \.self) { type in
                    let count = trophies.filter { $0.type == type }.count
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(type.color)
                        Text(type.rawValue)
                        Spacer()
                        Text("\(count)")
                            .font(.body.bold())
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Monthly chart

    @ViewBuilder
    private var monthlyChartSection: some View {
        let years = store.availableYears
        if !years.isEmpty {
            let chartYear = selectedChartYear ?? years.first ?? Calendar.current.component(.year, from: Date())
            let data = monthlyData(for: chartYear)
            let maxCount = data.map(\.count).max() ?? 10

            Section {
                Picker("Year", selection: Binding(
                    get: { chartYear },
                    set: { selectedChartYear = $0 }
                )) {
                    ForEach(years, id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .onAppear {
                    if selectedChartYear == nil { selectedChartYear = years.first }
                }

                Chart {
                    ForEach(data, id: \.month) { item in
                        AreaMark(
                            x: .value("Month", item.shortMonth),
                            y: .value("Trophies", item.count)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green.opacity(0.6), .green.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Month", item.shortMonth),
                            y: .value("Trophies", item.count)
                        )
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Month", item.shortMonth),
                            y: .value("Trophies", item.count)
                        )
                        .foregroundStyle(.green)
                        .symbolSize(item.count > 0 ? 30 : 0)
                    }

                    if let selected = selectedChartMonth,
                       let item = data.first(where: { $0.shortMonth == selected }) {
                        RuleMark(x: .value("Month", item.shortMonth))
                            .foregroundStyle(.gray.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                            .annotation(position: .top) {
                                VStack(spacing: 2) {
                                    Text(item.fullMonth)
                                        .font(.caption2.bold())
                                    Text("\(item.count) trophies")
                                        .font(.caption2)
                                }
                                .padding(6)
                                .background(Color(.systemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .shadow(radius: 2)
                            }
                    }
                }
                .frame(height: 180)
                .chartYScale(domain: 0...(maxCount + max(5, maxCount / 5)))
                .chartYAxis { AxisMarks(position: .leading) }
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let origin = geo[proxy.plotFrame!].origin
                                        let x = value.location.x - origin.x
                                        if let month: String = proxy.value(atX: x) {
                                            selectedChartMonth = month
                                        }
                                    }
                                    .onEnded { _ in
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            selectedChartMonth = nil
                                        }
                                    }
                            )
                    }
                }
                .padding(.vertical, 8)

                let topMonths = data.filter { $0.count > 0 }.sorted { $0.count > $1.count }.prefix(3)
                if !topMonths.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Best months")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        ForEach(Array(topMonths.enumerated()), id: \.offset) { index, item in
                            HStack {
                                Text("\(index + 1).")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                                    .frame(width: 20)
                                Text(item.fullMonth)
                                    .font(.caption.bold())
                                Spacer()
                                Text("\(item.count) trophies")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Activity breakdown

    private var activityBreakdownSection: some View {
        Section {
            TrophyActivityChartsView(
                trophies: store.games
                    .flatMap { $0.trophies }
                    .filter { $0.isUnlocked && $0.unlockedDate != nil }
            )
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
    }

    // MARK: - Platform stats

    private var platformStatsSection: some View {
        Section {
            Picker("Platform", selection: Binding(
                get: { currentPlatform },
                set: { selectedPlatform = $0 }
            )) {
                ForEach(
                    [Platform.ps5, .ps4, .vita, .ps3].filter { store.usedPlatforms.contains($0) },
                    id: \.self
                ) { platform in
                    Text(platform.rawValue).tag(platform)
                }
            }
            .onAppear {
                if selectedPlatform == nil {
                    selectedPlatform = store.usedPlatforms.first(where: { $0 == .ps5 })
                        ?? store.usedPlatforms.first(where: { $0 == .ps4 })
                        ?? store.usedPlatforms.first
                }
            }

            HStack {
                StatBadge(value: "\(store.games(for: currentPlatform).count)", label: "Games")
                Spacer()
                StatBadge(value: "\(store.completedGames(for: currentPlatform))", label: "Completed")
                Spacer()
                StatBadge(value: "\(store.platinums(for: currentPlatform))", label: "Platinums")
                Spacer()
                StatBadge(value: "\(store.totalPoints(for: currentPlatform))", label: "Points")
            }
            .padding(.vertical, 8)

            HStack {
                Text("Completion")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(String(format: "%.2f%%", store.completionPercentage(for: currentPlatform)))
                    .font(.body.bold())
            }

            HStack {
                Text("Earned trophies")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(store.unlockedTrophies(for: currentPlatform))")
                    .font(.body.bold())
            }

            HStack {
                Text("Unearned trophies")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(store.unearnedTrophies(for: currentPlatform))")
                    .font(.body.bold())
            }

            ForEach(TrophyType.displayOrder, id: \.self) { type in
                let count = store.games(for: currentPlatform).reduce(0) { total, game in
                    total + game.trophies.filter { $0.type == type && $0.isUnlocked }.count
                }
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(type.color)
                    Text(type.rawValue)
                    Spacer()
                    Text("\(count)")
                        .font(.body.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private struct MonthData {
        let month: Int
        let count: Int
        let shortMonth: String
        let fullMonth: String
    }

    private func monthlyData(for year: Int) -> [MonthData] {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let trophies = store.trophiesUnlocked(in: year)

        return (1...12).map { month in
            let count = trophies.filter { trophy in
                guard let date = trophy.unlockedDate else { return false }
                return calendar.component(.month, from: date) == month
            }.count
            return MonthData(
                month: month,
                count: count,
                shortMonth: formatter.shortMonthSymbols[month - 1],
                fullMonth: formatter.monthSymbols[month - 1]
            )
        }
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.monthSymbols[month - 1]
    }
}
