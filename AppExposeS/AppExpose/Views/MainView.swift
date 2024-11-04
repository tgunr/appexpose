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
            .background(
                NavigationLink(destination: AppFolderDetailViewWrapper(selectedEntry: $selectedEntry), isActive: Binding(get: {
                    return selectedEntry != nil
                }, set: { value in
                    if !value {
                        selectedEntry = nil
                    }
                })) {
                    EmptyView()
                }
            )
            .navigationTitle("Main View")
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
             LazyVGrid(columns: [
                 GridItem(.adaptive(minimum: 120)), // for debug
             ]) {
                 if !filteredEntries.isEmpty {
                     ForEach($filteredEntries, id: \.id) { entry in
                         AppFolderView(entry: entry, showFilter: $showFilter, canSelect: $canSelect, onSelected: { selectedEntry in
                             let _ = symlog.value("\(#function)  selectedEntry: \(selectedEntry.name ?? "none")")
                             self.selectedEntry = selectedEntry
                         })
                     }
                 } else {
                     ProgressView()
                 }
             }
         }
     }
   }

// Wrapper view for NavigationLink destination
struct AppFolderDetailViewWrapper: View {
    @Binding var selectedEntry: AppEntry?

    var body: some View {
        if let unwrappedEntry = selectedEntry {
            AppFolderDetailView(entry: .constant(unwrappedEntry))
        } else {
            EmptyView()
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
