//
//  SubfolderView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.
//

import SwiftUI

struct SubfolderView: View {
    @Binding var filteredEntries: [AppEntry]
    @Binding var showFilter: ShowFilter
    @Binding var canSelect: Bool
    @State var sortOption: SortOption
    @State var sEntries: [AppEntry]?
    @State private var selectedEntry: AppEntry?

    private var sortedEntries: [AppEntry] {
        let sortedEntries = filteredEntries.sorted { $0.name! < $1.name! }
        return sortedEntries
    }

    private func sortEntries(_ entry1: AppEntry, _ entry2: AppEntry) -> Bool {
        switch sortOption {
        case .name:
            return (entry1.name ?? "").localizedStandardCompare(entry2.name ?? "") == .orderedAscending
        case .addedDate:
            return (entry1.addedDate ?? .distantPast) < (entry2.addedDate ?? .distantPast)
        }
    }

    var body: some View {
        ForEach(sortedEntries.indices, id: \.self) { index in
            AppFolderView(
                entry: Binding(
                    get: { sortedEntries[index] },
                    set: { filteredEntries[index] = $0 }
                ),
                showFilter: $showFilter,
                canSelect: $canSelect
                onSelected: selectedEntry
            )
        }
    }
}

#Preview {
    @Previewable @State var showFilter: ShowFilter = .all
    @Previewable @State var canSelect: Bool = false
    @Previewable @State var filteredEntries: [AppEntry] = AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
    SubfolderView(
        filteredEntries: $filteredEntries,
        showFilter: .constant(.all),
        canSelect: $canSelect,
        sortOption: .name
    )
}
