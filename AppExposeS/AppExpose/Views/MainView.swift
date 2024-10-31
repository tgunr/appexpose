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

    func sortEntries(_ entries: [AppEntry], by sortOption: SortOption) -> [AppEntry] {
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

struct MainView: View {
    @Binding var searchText: String
    @Binding var showFilter: ShowFilter
    @State var sortOption: SortOption = .name
    @Binding var filteredEntries: [AppEntry]
    let appData: AppData
    @State private var isShowingSheet = false
    @StateObject var folderEntries = FolderEntries()

    var sortView: some View {
        Picker("Sort by", selection: $sortOption) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    var filterView: some View {
        Group {
            Picker("Filter", selection: $showFilter) {
                ForEach(ShowFilter.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    var headerView: some View {
        VStack {
            SearchBar(text: $searchText)
            sortView
            filterView
        }
    }

    var sortedEntries: [FolderData] {
        let (_, folderDataArray) = folderEntries.entries
        symlog.value("sortedEntries: sortedEntries: \(folderEntries.entries)")

        switch sortOption {
        case .name:
            return folderDataArray.sorted { $0.name < $1.name }
        case .addedDate:
            return folderDataArray.sorted { folder1, folder2 in
                let folder1Date = folder1.groupedEntries.values.flatMap { $0.map { $0.addedDate ?? .distantPast } }.max() ?? .distantPast
                let folder2Date = folder2.groupedEntries.values.flatMap { $0.map { $0.addedDate ?? .distantPast } }.max() ?? .distantPast
                return folder1Date < folder2Date
            }
        }
    }

    var folderList: some View {
        symlog.debug("folderList filteredEntries: \(filteredEntries)")
        return ForEach(sortedEntries, id: \.id) { folder in
            FolderSectionView(folder: folder, showFilter: $showFilter, sortOption: $sortOption)
        }
    }

    var appsView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 64)),
            ]) {
                Group {
//                    if hasLoaded {
                    if !filteredEntries.isEmpty {
                        ForEach(filteredEntries, id: \.id) { entry in
                            AppFolderView(entry: entry, showFilter: $showFilter)
                        }
                    } else {
                        ProgressView()
                    }
//                    } else {
//                        ProgressView()
//                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            headerView
                .padding()
            if $filteredEntries.isEmpty {
                HStack {
                    Spacer()
                    Text("No Entries")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .lineLimit(2)
                        .background(Color.red.opacity(0.2))
                    Spacer()
                }
            } else {
                appsView
            }
            Spacer()
        }
//        .onChange(of: sortOption) { oldValue, newValue in
//            symlog.value("sortOption changed from \(oldValue) to \(newValue)")
//            updateFilteredEntries()
//        }
//        .onChange(of: showFilter) { oldValue, newValue in
//            symlog.value("showFilter changed from \(oldValue) to \(newValue)")
//            updateShowFilter()
//        }
//        .onChange(of: appData.appFolders) { _, _ in
//            symlog.value("appData.appFolders changed \(appData.appFolders.count)")
//            updateFolderEntries()
//        }
    }

    func updateFolderEntries() {
        symlog.debug("\(#function) updateFolderEntries called")
        let folderDataArray = appData.appFolders.compactMap { folder -> FolderData? in
            symlog.debug("showFilter: \(showFilter)")
            let filteredEntries = folder.entries.filter { entry in
                symlog.debug("entry.hasMyCustomIcon: \(entry.hasMyCustomIcon)")
                symlog.debug("entry.isFolder: \(entry.isFolder)")
                symlog.debug("entry.isApp: \(entry.isApp)")
                switch showFilter {
                case .all:
                    return true
                case .exposed:
                    return entry.hasMyCustomIcon
                case .unmodified:
                    return !entry.hasMyCustomIcon && entry.isFolder && !entry.isApp
                }
            }

            let grouped = Dictionary(grouping: filteredEntries) { entry in
                let path = entry.appURL.deletingLastPathComponent().path
                let check = path.replacingOccurrences(of: "^/Users/[^/]+", with: "~", options: .regularExpression)
                symlog.debug("grouped path: \(check)")
                return check
            }
            if grouped.isEmpty {
                return nil
            }
            return FolderData(id: folder.id, name: folder.name, groupedEntries: grouped)
        }
        DispatchQueue.main.async {
            symlog.debug("folderDataArray: \(folderDataArray)")
            self.folderEntries.update(folderDataArray)
        }
    }

//    func updateShowFilter() {
//        symlog.entry("\(#function)")
//        switch showFilter {
//        case .all:
//            filteredEntries = appData.appFolders.reduce(into: [:]) { $0[$1.name] = $1.entries }
//        case .exposed:
//            filteredEntries = appData.appFolders.reduce(into: [:]) { result, folder in
//                result[folder.name] = folder.entries.filter { entry in
//                    entry.hasMyCustomIcon
//                }
//            }
//        case .unmodified:
//            filteredEntries = appData.appFolders.reduce(into: [:]) { result, folder in
//                result[folder.name] = folder.entries.filter { entry in
//                    !entry.hasMyCustomIcon && entry.isFolder && !entry.isApp
//                }
//            }
//        }
//        filteredEntries = filteredEntries
//    }
    
//    func updateFilteredEntries() {
//        symlog.entry("\(#function)")
//
//        switch sortOption {
//        case .name:
//            filteredEntries = appData.appFolders.reduce(into: [:]) { $0[$1.name] = $1.entries }
//        case .addedDate:
//            filteredEntries = appData.appFolders.reduce(into: [:]) { result, folder in
//                result[folder.name] = folder.entries.sorted { $0.addedDate! < $1.addedDate! }
//            }
//        }
//        filteredEntries = filteredEntries
//    }
}

#Preview {
    @Previewable @State var showFilter: ShowFilter = .all
    @Previewable @State var sortOption: SortOption = .name
    @Previewable @State var filteredEntries: [AppEntry] = AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
    var appData = AppData()
    MainView(searchText: .constant(""), showFilter: $showFilter, filteredEntries: $filteredEntries, appData: appData)

}
