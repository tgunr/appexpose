//
//  AppFoldersViews.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import SwiftUI

enum ShowOption: Int, CaseIterable, Identifiable {
    case all = 1
    case exposed = 2
    case unmodified = 3

    var id: Int { rawValue }

    var description: String {
        switch self {
        case .all: return "All"
        case .exposed: return "Exposed"
        case .unmodified: return "Unmodified"
        }
    }
}

struct MainView: View {
    @Binding var searchText: String
    @Binding var showOptions: ShowOption
    var filteredEntries: [String: [AppEntry]]
    let appData: AppData

    private var groupedFolderEntries: [(UUID, String, [String: [AppEntry]])] {
        let folderOrder = Dictionary(uniqueKeysWithValues: appData.appFolders.enumerated().map { ($0.element.id, $0.offset) })

        let theFolders = appData.appFolders
            .map { folder in
                (folder.id, folder.name, Dictionary(grouping: folder.entries) { entry in
                    let path = entry.appURL.deletingLastPathComponent().path
                    let check = path.replacingOccurrences(of: "^/Users/[^/]+", with: "~", options: .regularExpression)
                    return check
                })
            }
            .sorted { folderOrder[$0.0, default: 0] < folderOrder[$1.0, default: 0] }
        return theFolders
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(groupedFolderEntries, id: \.0) { _, _, subfolders in
                        ForEach(subfolders.keys.sorted(), id: \.self) { subfolderName in
                            SubfolderView(showOptions: $showOptions, filteredEntries: filteredEntries, subfolderName: subfolderName)
                        }
                    }
                }
            }
            .onChange(of: showOptions) { oldValue, newValue in
                symlog.debug("showOptions changed from \(oldValue) to \(newValue)")
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .cornerRadius(8)

            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct SubfolderView: View {
    @Binding var showOptions: ShowOption
    var filteredEntries: [String: [AppEntry]]
    let subfolderName: String

    var body: some View {
        Section(header: Text(subfolderName).font(.title)) {
            ForEach(Array(filteredEntries[subfolderName] ?? []).indices, id: \.self) { index in
                let entry = filteredEntries[subfolderName]![index]
                switch showOptions {
                case .all:
                    AppFolderView(entry: entry, showOptions: $showOptions)
                case .unmodified:
                    if entry.isNotSpecial() {
                        AppFolderView(entry: entry, showOptions: $showOptions)
                    }
                case .exposed:
                    if !entry.hasMyCustomIcon {
                        AppFolderView(entry: entry, showOptions: $showOptions)
                    }
                }
            }
        }
    }
}

struct AppFoldersView: View {
    @EnvironmentObject var appData: AppData
    @State var selectedItem: String? = nil
    @State private var currentFolder: String = "/"
    @State private var unmodified: Bool = false
    @State private var showOptions: ShowOption = .all
    @State private var subfolders: [String: [AppEntry]] = [:]
    @State private var searchText: String = ""

    var filteredEntries: [String: [AppEntry]] {
        subfolders.mapValues { entries in
            entries.filter { entry in
                let nameMatch = searchText.isEmpty || ((entry.name?.lowercased().contains(searchText.lowercased())) != nil)

                switch showOptions {
                case .exposed:
                    return nameMatch && entry.hasMyCustomIcon
                case .unmodified:
                    return nameMatch && entry.isFolder && !entry.hasMyCustomIcon
                case .all:
                    return nameMatch
                }
            }
        }
    }

    var body: some View {
//        let _ = symlog.debug("AppFoldersViews")
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Picker("Show", selection: $showOptions) {
                        ForEach(ShowOption.allCases) { option in
                            Text(option.description).tag(option)
                        }
                    }
                    .pickerStyle(.radioGroup)
//                        .onChange(of: showOptions) { _, new in
//                        switch new {
//                        case .all:
//                            unmodified = false
//                        case .unmodified:
//                            unmodified = true
//                        case .exposed:
//                            unmodified = false
//                        }
//                    }
                    Spacer()
                }
                .padding(.top)
                .frame(width: 140)
                MainView(searchText: $searchText, showOptions: $showOptions, filteredEntries: filteredEntries, appData: appData)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: selectedItem)
        .task {
            symlog.info("Fetching Apps")
            await fetchApps()
        }
    }

    private func fetchApps() async {
        var updatedFolders = appData.appFolders
        for index in updatedFolders.indices {
            let entries = AppEntry.scanApplications(atPath: updatedFolders[index].url.path, currentDirectory: nil)
            updatedFolders[index].entries = entries
            symlog.value("Folder \(updatedFolders[index].name) created with \(entries.count) child entries")
        }
        appData.appFolders = updatedFolders
        // Ensure subfolders are updated
        subfolders = Dictionary(grouping: appData.appFolders.flatMap { $0.entries }) { entry in
            let path = entry.appURL.deletingLastPathComponent().path
            let check = path.replacingOccurrences(of: "^/Users/[^/]+", with: "~", options: .regularExpression)
            return check
        }
    }
}

struct AppFoldersViews_Previews: PreviewProvider {
    static let mockAppData: AppData = {
        symlog.info("mockAppData")
        let data = AppData()
        let entries = AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
        let folder = Folder(id: UUID(), name: "Apps", url: URL(fileURLWithPath: "/Users/davec/Applications"), entries: entries)
        data.appFolders = [folder]
        return data
    }()

    static var previews: some View {
//        let folders = [Folder(id: 1, name: "Apps", url: URL(fileURLWithPath: "/Users/davec/Applications"))]
        AppFoldersView()
            .environmentObject(mockAppData)
    }
}
