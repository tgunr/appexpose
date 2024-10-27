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

enum SortOption: String, CaseIterable {
    case name = "Name"
    case modifiedDate = "Modified Date"
    case creationDate = "Creation Date"
    case addedDate = "Added Date"
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

struct AppFoldersView: View {
    @EnvironmentObject var appData: AppData
    @State var selectedItem: String? = nil
    @State private var currentFolder: String = "/"
    @State private var unmodified: Bool = false
    @State private var showOptions: ShowOption = .all
    @State private var subfolders: [String: [AppEntry]] = [:]
    @State private var searchText: String = ""
    @State private var filteredEntries: [String: [AppEntry]] = [:]
    @State private var refreshTrigger: UUID?

    var entries: [String: [AppEntry]] {
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
        VStack {
            MainView(searchText: $searchText, showOptions: $showOptions, filteredEntries: $filteredEntries, appData: appData)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: selectedItem)
        .task {
            symlog.info("Fetching Apps")
            await fetchApps()
        }
        .onChange(of: entries) { _, newEntries in
            filteredEntries = newEntries
            if refreshTrigger == nil {
                refreshTrigger = UUID()
            }
        }
        .id(refreshTrigger)
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
    static let preview = Preview()

    static var previews: some View {
        AppFoldersView()
            .environmentObject(preview.appData)
    }
}
