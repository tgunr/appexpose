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
    @State private var showDetailView = false

    init(searchText: Binding<String>, showFilter: Binding<ShowFilter>, sortOption: Binding<SortOption>, filteredEntries: Binding<[AppEntry]>, appData: AppData, entries: @escaping () -> [AppEntry]) {
        _searchText = searchText
        _showFilter = showFilter
        _sortOption = sortOption
        _filteredEntries = filteredEntries
        self.appData = appData
        self.entries = entries
    }

    var body: some View {
        //        NavigationView {
        if showDetailView {
            if let selectedEntry = selectedEntry {
                AppFolderDetailView(entry: .constant(selectedEntry), showDetailView: $showDetailView)
            } else {
                EmptyView()
            }
        } else {
            VStack {
                headerView
                if filteredEntries.isEmpty {
                    emptyStateView
                } else {
                    appsView
                }
                Spacer()
            }
            //            .navigationTitle("Main View")
            //        }
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
                ForEach(filteredEntries) { entry in
                    Button(action: {
                        showDetailView = true
                        selectedEntry = entry
                    }) {
                        AppFolderView(entry: .constant(entry), showFilter: $showFilter, canSelect: $canSelect)
                    }
                }
            }
        }
    }

    var emptyStateView: some View {
        HStack {
            Spacer()
            Text("No Entries")
                .font(.largeTitle)
                .foregroundColor(.red)
                .lineLimit(2)
                .background(Color.red.opacity(0.2))
            Spacer()
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
