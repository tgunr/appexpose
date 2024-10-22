//
//  MainView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.
//

import SwiftUI

struct MainView: View {
    @Binding var searchText: String
    @Binding var showOptions: ShowOption
    @Binding var filteredEntries: [String: [AppEntry]]
    @State var sortOption: SortOption = .name
    let appData: AppData

    private var groupedFolderEntries: [(UUID, String, [String: [AppEntry]])] {
        let folderOrder = Dictionary(uniqueKeysWithValues: appData.appFolders.enumerated().map { ($0.element.id, $0.offset) })
        symlog.value("Folders: \(appData.appFolders.count) child entries")

        let theFolders = appData.appFolders
            .map { folder in
                (folder.id, folder.name, Dictionary(grouping: folder.entries) { entry in
                    let path = entry.appURL.deletingLastPathComponent().path
                    let check = path.replacingOccurrences(of: "^/Users/[^/]+", with: "~", options: .regularExpression)
                    return check
                })
            }
            .sorted { folderOrder[$0.0, default: 0] < folderOrder[$1.0, default: 0] }
        symlog.value("\(#function)• Folders: \(theFolders.count) child entries")
        return theFolders
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            Picker("", selection: $sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
//            .padding()

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300))], alignment: .center, spacing: 20) {
                    ForEach(groupedFolderEntries, id: \.0) { _, _, subfolders in
                        let _ = symlog.value("Found \(subfolders.count) subfolders")
                        ForEach(subfolders.keys.sorted(), id: \.self) { _ in
//                            RoundedRectangle(cornerRadius: 5)
//                                .fill(Color.blue)
//                                .frame(width: 50, height: 50)
                            SubfolderView(
                                subfolderName: subfolders.keys.sorted().first ?? "YourSubfolderName",
                                filteredEntries: $filteredEntries,
                                showOptions: $showOptions,
                                sortOption: sortOption
                            )
                        }
                    }
                }
                .padding()
                .border(.secondary)
            }
            .onChange(of: showOptions) { oldValue, newValue in
                symlog.debug("showOptions changed from \(oldValue) to \(newValue)")
            }
        }
    }
}

#Preview {
    let preview = Preview()
    MainView(searchText: .constant(""), showOptions: preview.$showOptions, filteredEntries: .constant(["Applications": preview.entries]), sortOption: preview.sortOption, appData: preview.appData)
}
