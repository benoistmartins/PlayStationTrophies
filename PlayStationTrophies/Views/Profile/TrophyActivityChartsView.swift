//
//  TrophyActivityChartsView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 07/06/2026.
//

import SwiftUI
import Charts

struct TrophyActivityChartsView: View {
    let trophies: [Trophy]

    // MARK: - Data

    private var dayData: [(label: String, count: Int, color: Color)] {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let colors: [Color] = [.blue, .indigo, .purple, .pink, .orange, .yellow, .green]
        let calendar = Calendar.current
        return days.enumerated().map { index, day in
            let weekday = index + 2 > 7 ? 1 : index + 2
            let count = trophies.filter {
                guard let date = $0.unlockedDate else { return false }
                return calendar.component(.weekday, from: date) == weekday
            }.count
            return (label: day, count: count, color: colors[index])
        }
        .filter { $0.count > 0 }
        .sorted { $0.count > $1.count }
    }

    private var slotData: [(label: String, count: Int, color: Color)] {
        let slots: [(String, ClosedRange<Int>, Color)] = [
            ("Morning", 6...11, .orange),
            ("Afternoon", 12...17, .yellow),
            ("Evening", 18...23, .indigo),
            ("Night", 0...5, .purple)
        ]
        let calendar = Calendar.current
        return slots.map { label, range, color in
            let count = trophies.filter {
                guard let date = $0.unlockedDate else { return false }
                let hour = calendar.component(.hour, from: date)
                return range.contains(hour)
            }.count
            return (label: label, count: count, color: color)
        }
        .filter { $0.count > 0 }
        .sorted { $0.count > $1.count }
    }

    private var seasonData: [(label: String, count: Int, color: Color)] {
        let calendar = Calendar.current
        let seasons: [(String, [Int], Color)] = [
            ("Spring", [3, 4, 5], .green),
            ("Summer", [6, 7, 8], .yellow),
            ("Autumn", [9, 10, 11], .orange),
            ("Winter", [12, 1, 2], .blue)
        ]
        return seasons.map { label, months, color in
            let count = trophies.filter {
                guard let date = $0.unlockedDate else { return false }
                let month = calendar.component(.month, from: date)
                return months.contains(month)
            }.count
            return (label: label, count: count, color: color)
        }
        .filter { $0.count > 0 }
        .sorted { $0.count > $1.count }
    }

    var body: some View {
        VStack(spacing: 24) {
            chartCard(
                title: "By day of week",
                icon: "calendar",
                data: dayData
            )
            chartCard(
                title: "By time of day",
                icon: "clock",
                data: slotData
            )
            chartCard(
                title: "By season",
                icon: "leaf",
                data: seasonData
            )
        }
    }

    // MARK: - Chart card

    private func chartCard(
        title: String,
        icon: String,
        data: [(label: String, count: Int, color: Color)]
    ) -> some View {
        let chartTotal = data.reduce(0) { $0 + $1.count }

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
            }

            if data.isEmpty {
                Text("No data available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                HStack(alignment: .center, spacing: 24) {
                    Chart(data, id: \.label) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(item.color)
                        .cornerRadius(4)
                    }
                    .frame(width: 130, height: 130)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(data, id: \.label) { item in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 8, height: 8)
                                Text(item.label)
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text("\(item.count)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(chartTotal > 0 ? Int(Double(item.count) / Double(chartTotal) * 100) : 0)%")
                                    .font(.caption.bold())
                                    .foregroundStyle(.primary)
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
