import SwiftUI

struct MainView: View {
    @Binding var searchText: String
    @Binding var showOptions: ShowOption
    @Binding var filteredEntries: [String: [AppEntry]]
    @State var sortOption: SortOption = .name
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
            Picker("", selection: $sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
//            .padding()

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(groupedFolderEntries, id: \.0) { _, _, subfolders in
                        ForEach(subfolders.keys.sorted(), id: \.self) { _ in
                            SubfolderView(
                                subfolderName: subfolders.keys.sorted().first ?? "YourSubfolderName",
                                filteredEntries: $filteredEntries,
                                showOptions: $showOptions,
                                sortOption: sortOption
                            )
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