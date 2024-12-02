//
//  MainView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.
//

import SwiftUI

struct SearchTextKey: EnvironmentKey {
    static let defaultValue: String = ""
}

struct UpdateSearchTextKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: (String) -> Void = { _ in }
}

struct SearchTextFocus: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var searchText: String {
        get { self[SearchTextKey.self] }
        set { self[SearchTextKey.self] = newValue }
    }

    var updateSearchText: (String) -> Void {
        get { self[UpdateSearchTextKey.self] }
        set { self[UpdateSearchTextKey.self] = newValue }
    }

    var isSearchFieldFocused: Bool {
        get { self[SearchTextFocus.self] }
        set { self[SearchTextFocus.self] = newValue }
    }
}

struct MainView: View {
    @Binding var searchText: String
    @Binding var showFilter: ShowFilter
    @Binding var sortOption: SortOption
    @Binding var filteredEntries: [AppEntry]
    let appData: AppData
    @State private var isShowingSheet = false
    @FocusState var isSearchFieldFocused: Bool
    let entries: () -> [AppEntry]
    @State private var canSelect = false
    @State private var selectedEntry: AppEntry?
    @State private var isNavigationActive = false
    @State private var selectedEntryID: UUID?

    init(searchText: Binding<String>, showFilter: Binding<ShowFilter>, sortOption: Binding<SortOption>, filteredEntries: Binding<[AppEntry]>, appData: AppData, entries: @escaping () -> [AppEntry]) {
        _searchText = searchText
        _showFilter = showFilter
        _sortOption = sortOption
        _filteredEntries = filteredEntries
        self.appData = appData
        self.entries = entries
    }

    var body: some View {
        NavigationStack {
            VStack {
                headerView
                if filteredEntries.isEmpty {
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
            .navigationTitle("Main View")
            .navigationDestination(for: UUID.self) { id in
                if let entry = filteredEntries.first(where: { entry in entry.id == id }) {
                    AppFolderDetailView(entry: .constant(entry))
                        .onAppear {
                            _ = symlog.value("AppFolderDetailView appeared for: \(entry.name ?? "unknown")")
                        }
                } else {
                    Text("Entry not found")
                        .onAppear {
                            _ = symlog.value("Entry not found for id: \(id)")
                        }
                }
            }
        }
    }

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
            SearchBar(searchText: $searchText, filteredEntries: $filteredEntries, isFocused: $isSearchFieldFocused, entries: { self.entries() })
            sortView
            filterView
            Button("Select", action: {
                canSelect.toggle()
            })
            Divider()
        }
        .padding()
    }

    var appsView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
                ForEach(filteredEntries, id: \.id) { entry in
                    NavigationLink(value: entry.id) {
                        AppFolderView(entry: .constant(entry), showFilter: $showFilter, canSelect: $canSelect, onSelected: { selectedEntry in
                            self.selectedEntry = selectedEntry
                            self.selectedEntryID = selectedEntry.id
                            _ = symlog.value("\(#function)  selectedEntry: \(selectedEntry.name ?? "none")")
                            _ = symlog.value("Navigation to AppFolderDetailView triggered for: \(selectedEntry.name ?? "unknown")")
                        })
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture {
                        _ = symlog.value("Tapped on: \(entry.name ?? "unknown")")
                        self.selectedEntryID = entry.id
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var showFilter: ShowFilter = .all
    @Previewable @State var sortOption: SortOption = .name
    @Previewable @State var filteredEntries: [AppEntry] = AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
    var appData = AppData()
    MainView(searchText: .constant(""), showFilter: $showFilter, sortOption: $sortOption, filteredEntries: $filteredEntries, appData: appData, entries: { AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil) })
}
