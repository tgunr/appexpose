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
    let groupedEntries: [String: [AppEntry]]
}

struct MainView: View {
    @Binding var searchText: String
    @Binding var showOptions: ShowFilter
    @Binding var filteredEntries: [String: [AppEntry]]
    @State var sortOption: SortOption = .name
    let appData: AppData
    @State private var hasLoaded = false

    var headerView: some View {
        Group {
            SearchBar(text: $searchText)
            Picker("", selection: $sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
        }
    }

    var body: some View {
        let folderEntries = appData.appFolders.map { folder -> FolderData in
            let grouped = Dictionary(grouping: folder.entries) { entry in
                let path = entry.appURL.deletingLastPathComponent().path
                let check = path.replacingOccurrences(of: "^/Users/[^/]+", with: "~", options: .regularExpression)
                return check
            }
            return FolderData(id: folder.id, name: folder.name, groupedEntries: grouped)
        }

        let folderOrder = Dictionary(uniqueKeysWithValues: appData.appFolders.enumerated().map { ($0.element.id, $0.offset) })

        let sortedEntries = folderEntries.sorted { folderOrder[$0.id, default: 0] < folderOrder[$1.id, default: 0] }

        VStack {
            headerView
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 64)),
                ]) {
                    ForEach(sortedEntries, id: \.id) { folder in
                        makeFolderSection(folder: folder)
                    }
                }
            }
            .padding()
        }

        .onChange(of: sortOption) { oldValue, newValue in
            symlog.debug("showOptions changed from \(oldValue) to \(newValue)")
            updateFilteredEntries()
        }
    }

    func updateFilteredEntries() {
        switch sortOption {
        case .name:
            filteredEntries = appData.appFolders.reduce(into: [:]) { $0[$1.name] = $1.entries }
        case .addedDate:
            filteredEntries = appData.appFolders.reduce(into: [:]) { result, folder in
                result[folder.name] = folder.entries.sorted { $0.addedDate! < $1.addedDate! }
            }
        }
    }

    func sortEntries(_ entries: [AppEntry], by sortOption: SortOption) -> [AppEntry] {
        switch sortOption {
        case .name:
            return entries.sorted { $0.name ?? "" < $1.name ?? "" }
        case .addedDate:
            return entries.sorted { $0.addedDate ?? .distantPast < $1.addedDate ?? .distantPast }
        }
    }

    func makeFolderSection(folder: FolderData) -> some View {
        let sortedKeys = folder.groupedEntries.keys.sorted()

        let folderList = Group {
            ForEach(sortedKeys, id: \.self) { key in
                Section(header: Text(key).font(.headline)) {
                    let entries = folder.groupedEntries[key] ?? []
                    let sortedEntries = sortEntries(entries, by: sortOption)
                    ForEach(sortedEntries, id: \.id) { entry in
                        AppFolderView(entry: entry, showFilter: $showOptions)
                    }
                }
            }
        }

        return Group {
            if hasLoaded {
                folderList
            } else {
                ProgressView()
            }
        }
        .onAppear {
            hasLoaded = true
        }
    }
}

#Preview {
    let preview = Preview()
    MainView(searchText: .constant(""), showOptions: preview.$showOptions, filteredEntries: .constant(["Applications": preview.entries]), sortOption: preview.sortOption, appData: preview.appData)
}
