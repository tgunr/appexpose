//
//  MainView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.
//

import SwiftUI

struct MainView: View {
    @Binding var searchText: String
    @Binding var showFilter: ShowFilter
    @State var sortOption: SortOption = .name
    @Binding var filteredEntries: [AppEntry]
    let appData: AppData
    @State private var isShowingSheet = false

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

}

#Preview {
    @Previewable @State var showFilter: ShowFilter = .all
    @Previewable @State var sortOption: SortOption = .name
    @Previewable @State var filteredEntries: [AppEntry] = AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
    var appData = AppData()
    MainView(searchText: .constant(""), showFilter: $showFilter, filteredEntries: $filteredEntries, appData: appData)

}
