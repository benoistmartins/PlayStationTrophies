//
//  AdvancedSearchView.swift
//  PlayStationTrophies
//
//  Created by Benoist Martins on 20/04/2026.
//

import SwiftUI

struct AdvancedSearchView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var filter: SearchFilter
    @State private var localFilter: SearchFilter

    init(filter: Binding<SearchFilter>) {
        self._filter = filter
        self._localFilter = State(initialValue: filter.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Search by name...", text: $localFilter.name)
                        .autocorrectionDisabled()
                }

                Section("Platform") {
                    ForEach([Platform.ps5, .ps4, .vita, .ps3], id: \.self) { platform in
                        HStack {
                            Text(platform.rawValue)
                            Spacer()
                            if localFilter.platforms.contains(platform) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if localFilter.platforms.contains(platform) {
                                localFilter.platforms.remove(platform)
                            } else {
                                localFilter.platforms.insert(platform)
                            }
                        }
                    }
                }

                Section("Platinum") {
                    ForEach(PlatinumFilter.allCases, id: \.self) { option in
                        HStack {
                            Text(option.rawValue)
                            Spacer()
                            if localFilter.platinumFilter == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { localFilter.platinumFilter = option }
                    }
                }

                Section("Progression") {
                    ForEach(ProgressionFilter.allCases, id: \.self) { option in
                        HStack {
                            Text(option.rawValue)
                            Spacer()
                            if localFilter.progressionFilter == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { localFilter.progressionFilter = option }
                    }
                }
            }
            .navigationTitle("Advanced search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        localFilter = SearchFilter()
                    }
                    .foregroundStyle(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        filter = localFilter
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}