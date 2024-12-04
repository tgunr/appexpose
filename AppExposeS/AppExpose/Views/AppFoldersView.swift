//
//  AppFoldersViews.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//
//
import SwiftUI
//
enum ShowFilter: String, CaseIterable {
    case all = "All"
    case exposed = "Exposed"
    case unmodified = "Unmodified"
}
//
enum SortOption: String, CaseIterable {
    case name = "Name"
    case addedDate = "Added Date"
}
//
struct SearchBar: View {
    @Binding var searchText: String
    @Binding var filteredEntries: [AppEntry]
    @Environment(\.updateSearchText) var updateSearchText
    var isFocused: FocusState<Bool>.Binding
    let entries: () -> [AppEntry]
//
    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("name", text: $searchText)
                    .onChange(of: searchText) { _, newValue in
                        updateSearchText(newValue)
                    }
                    .focused(isFocused)
            }
            .padding(7)
            .cornerRadius(8)
            
            if !searchText.isEmpty {
                Button(action: {
                    updateSearchText("")
                    self.searchText = ""
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
                .padding([.top, .bottom, .trailing], 4.0)
            }
        }
        .padding(.horizontal)
        .onChange(of: searchText) { _, _ in
            filteredEntries = entries()
        }
    }
}
//
struct AppFoldersView: View {
    @EnvironmentObject var appData: AppData
    @State var selectedItem: String? = nil
    @State private var currentFolder: String = "/"
    @State private var unmodified: Bool = false
    @State private var showFilter: ShowFilter = .all
    @State private var sortOption: SortOption = .name
    @State private var subfolders: [String: [AppEntry]] = [:]
    @State private var searchText: String = ""
    @FocusState private var isSearchFieldFocused: Bool
    @State private var filteredEntries: [AppEntry] = []
    @State private var refreshTrigger: UUID?
//
    var entries: [AppEntry] {
        let allEntries = appData.appFolders.flatMap { folder in
            subfolders[folder.url.path] ?? []
        }
//
        symlog.value("All Entries Count: \(allEntries.count)")
//
        let filteredEntries = allEntries.filter { entry in
            switch showFilter {
            case .all:
                return true
            case .exposed:
                return entry.hasMyCustomIcon
            case .unmodified:
                return entry.isFolder && !entry.hasMyCustomIcon && !entry.isApp
            }
        }
//
        symlog.value("Filtered Entries Count (before search): \(filteredEntries.count)")
//
        let searchFilteredEntries = filteredEntries.filter { entry in
            searchText.isEmpty || (entry.name?.lowercased().contains(searchText.lowercased()) ?? false)
        }
//
        symlog.value("Search Filtered Entries Count: \(searchFilteredEntries.count)")
//
        return searchFilteredEntries.sorted { entry1, entry2 in
            switch sortOption {
            case .name:
                return (entry1.name ?? "") < (entry2.name ?? "")
            case .addedDate:
                return (entry1.addedDate ?? .distantPast) > (entry2.addedDate ?? .distantPast)
            }
        }
    }
//
    var body: some View {
        VStack {
            MainView(searchText: $searchText, showFilter: $showFilter, sortOption: $sortOption, filteredEntries: $filteredEntries, appData: appData, entries: { self.entries })
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: selectedItem)
        .onAppear {
            symlog.info("AppFoldersView Appeared")
        }
        .task {
            symlog.info("Fetching Apps")
            await fetchApps()
            filteredEntries = entries
            symlog.value("task: Fetched Apps, filteredEntries: \(filteredEntries.count)")
//
            if refreshTrigger == nil {
                refreshTrigger = UUID()
            }
        }
        .onChange(of: showFilter) { _, _ in
            filteredEntries = entries
            refreshTrigger = UUID()
        }
        .onChange(of: sortOption) { _, _ in
            filteredEntries = entries
            refreshTrigger = UUID()
        }
        .id(refreshTrigger)
    }
//
    private func fetchApps() async {
        var updatedSubfolders: [String: [AppEntry]] = [:]
        var updatedAppFolders: [Folder] = []
        
        for var folder in appData.appFolders {
            let entries = AppEntry.scanApplications(atPath: folder.url.path, currentDirectory: nil)
            folder.entries = entries
            updatedAppFolders.append(folder)
            
            symlog.value("AppFoldersView - fetchApps: Folder \(folder.name) created with \(entries.count) child entries")
            
            updatedSubfolders[folder.url.path] = entries
            
            let folderEntry = AppEntry(withURL: folder.url)
            for entry in entries {
                entry.directoryEntry = folderEntry
            }
        }
        
        appData.appFolders = updatedAppFolders
        subfolders = updatedSubfolders
        symlog.value("AppFoldersView - fetchApps: Total subfolders created: \(subfolders.count)")
    }
}
//
struct AppFoldersViews_Previews: PreviewProvider {
    static let preview = Preview()
//
    static var previews: some View {
        AppFoldersView()
            .environmentObject(preview.appData)
    }
}
