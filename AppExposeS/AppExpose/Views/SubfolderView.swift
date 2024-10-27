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
    @State var sortOption: SortOption
    @State var sEntries: [AppEntry]?
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
        ForEach(sortedEntries, id: \.id) { entry in
            AppFolderView(entry: entry, showFilter: $showFilter)
            .padding(.top)
        }
    }
}

struct SubfolderView_Previews: PreviewProvider {
    static let preview = Preview()

    static var previews: some View {
        SubfolderView(
            filteredEntries: .constant(preview.entries),
//            filteredEntries: .constant(["Applications": preview.entries]),
            showFilter: .constant(.all),
            sortOption: .name
        )
    }
}
