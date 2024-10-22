//
//  SubfolderView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.
//


import SwiftUI

struct SubfolderView: View {
    let subfolderName: String
    @Binding var filteredEntries: [String: [AppEntry]]
    @Binding var showOptions: ShowOption
    @State var sortOption: SortOption

    private var sortedEntries: [(String, [AppEntry])] {
        let sortedDictionary = filteredEntries.mapValues { entries in
            entries.sorted { entry1, entry2 in
                sortEntries(entry1, entry2)
            }
        }

        return sortedDictionary.sorted { $0.key < $1.key }
    }

    private func sortEntries(_ entry1: AppEntry, _ entry2: AppEntry) -> Bool {
        switch sortOption {
        case .name:
            return (entry1.name ?? "").localizedStandardCompare(entry2.name ?? "") == .orderedAscending
        case .modifiedDate:
            return (entry1.modifiedDate ?? .distantPast) < (entry2.modifiedDate ?? .distantPast)
        case .creationDate:
            return (entry1.createdDate ?? .distantPast) < (entry2.createdDate ?? .distantPast)
        case .addedDate:
            return (entry1.addedDate ?? .distantPast) < (entry2.addedDate ?? .distantPast)
        }
    }

    var body: some View {
        VStack {
            ForEach(sortedEntries, id: \.0) { key, entries in
                Section(header: Text(key)) {
                    ForEach(entries, id: \.id) { entry in
                        switch showOptions {
                        case .all:
                            AppFolderView(entry: entry, showOptions: $showOptions)
                        case .unmodified:
                            if !entry.isSpecial {
                                AppFolderView(entry: entry, showOptions: $showOptions)
                            }
                        case .exposed:
                            if !entry.hasMyCustomIcon {
                                AppFolderView(entry: entry, showOptions: $showOptions)
                            }
                        }
                    }
                }
                .padding(.top)
            }
        }
    }
}

struct SubfolderView_Previews: PreviewProvider {
    static let preview = Preview()

    static var previews: some View {
        SubfolderView(
            subfolderName: "Applications",
            filteredEntries: .constant(["Applications": preview.entries]),
            showOptions: .constant(.all),
            sortOption: .name
        )
    }
}

