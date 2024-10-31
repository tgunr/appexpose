//
//  MainView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.
//

import SwiftUI

struct FolderData {
    let id: UUID
    let name: String
    let groupedEntries: [String: [EntryFilterData]]
}

struct FolderSectionView: View {
    let folder: FolderData
    @Binding var showFilter: ShowFilter
    @Binding var sortOption: SortOption

    var body: some View {
        let sortedKeys = folder.groupedEntries.keys.sorted()

        return Group {
            ForEach(sortedKeys, id: \.self) { key in
                Section(header: Text(key)) {
                    let entries = folder.groupedEntries[key] ?? []
                    let sortedEntries = sortEntries(entries, by: sortOption)
                    ForEach(sortedEntries, id: \.id) { entry in
                        AppFolderView(entry: entry, showFilter: $showFilter)
                    }
                }
            }
        }
    }

    func sortEntries(_ entries: [EntryFilterData], by sortOption: SortOption) -> [EntryFilterData] {
        switch sortOption {
        case .name:
            return entries.sorted { $0.name ?? "" < $1.name ?? "" }
        case .addedDate:
            return entries.sorted { $0.addedDate ?? .distantPast < $1.addedDate ?? .distantPast }
        }
    }
}

class FolderEntries: ObservableObject {
    @Published var entries: (Bool, [FolderData]) = (false, [])

    func update(_ entries: [FolderData]) {
        self.entries = (true, entries)
    }
}

struct EntryFilterData {
    let id: UUID
    let name: String
    let hasMyCustomIcon: Bool
    let isFolder: Bool
    let isApp: Bool
    let addedDate: Date?

    func matchesSearch(_ searchText: String) -> Bool {
        searchText.isEmpty || name.localizedCaseInsensitiveContains(searchText)
    }
}

class FolderEntriesViewModel: ObservableObject {
    @Published var allEntries: [FolderData] = []
    @Published var sortOption: SortOption = .name
    @Published var showFilter: ShowFilter = .all
    @Published var searchText: String = ""

    @MainActor
    var filteredAndSortedEntries: [FolderData] {
        allEntries
            .map { folder in
                FolderData(
                    id: folder.id,
                    name: folder.name,
                    groupedEntries: folder.groupedEntries.mapValues { entries in
                        entries.filter { entry in
                            let nameMatch = entry.matchesSearch(searchText)
                            switch showFilter {
                            case .all: return nameMatch
                            case .exposed: return nameMatch && entry.hasMyCustomIcon
                            case .unmodified: return nameMatch && entry.isFolder && !entry.hasMyCustomIcon && !entry.isApp
                            }
                        }
                    }
                )
            }
            .filter { !$0.groupedEntries.isEmpty }
            .sorted { lhs, rhs in
                switch sortOption {
                case .name:
                    return lhs.name < rhs.name
                case .addedDate:
                    let lhsDate = lhs.groupedEntries.values.flatMap { $0 }.compactMap { $0.addedDate }.max() ?? .distantPast
                    let rhsDate = rhs.groupedEntries.values.flatMap { $0 }.compactMap { $0.addedDate }.max() ?? .distantPast
                    return lhsDate < rhsDate
                }
            }
    }

    func updateEntries(_ folders: [Folder]) {
        self.allEntries = folders.map { folder in
            FolderData(
                id: folder.id,
                name: folder.name,
                groupedEntries: ["": folder.entries.map { entry in
                    EntryFilterData(
                        id: entry.id,
                        name: entry.name ?? "",
                        hasMyCustomIcon: entry.hasMyCustomIcon,
                        isFolder: entry.isFolder,
                        isApp: entry.isApp,
                        addedDate: entry.addedDate
                    )
                }]
            )
        }
    }
}

extension AppEntry {
    func matchesSearch(_ searchText: String) -> Bool {
        name?.localizedCaseInsensitiveContains(searchText) == true
    }
}

struct MainView: View {
    @StateObject private var viewModel = FolderEntriesViewModel()
    @ObservedObject var appData: AppData

    var body: some View {
        VStack {
            headerView
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 64))]) {
                    ForEach(viewModel.filteredAndSortedEntries, id: \.id) { folder in
                        FolderSectionView(folder: folder, showFilter: $viewModel.showFilter, sortOption: $viewModel.sortOption)
                    }
                }
            }
        }
        .onAppear {
            viewModel.updateEntries(appData.appFolders)
        }
        .onChange(of: appData.appFolders) { old, newValue in
            viewModel.updateEntries(newValue)
        }
    }

    var headerView: some View {
        VStack {
            SearchBar(text: $viewModel.searchText)
            Picker("Sort by", selection: $viewModel.sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            Picker("Filter", selection: $viewModel.showFilter) {
                ForEach(ShowFilter.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

//#Preview {
//    let preview = Preview()
//    MainView(searchText: .constant(""), showFilter: preview.$showFilter, filteredEntries: .constant(["Applications": preview.entries]), sortOption: preview.sortOption, appData: preview.appData)
//}
