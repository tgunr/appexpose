//
//  AppFoldersViews.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import RemoteImage
import SwiftUI

struct RemoteImageView: View {
    let url: URL

    var body: some View {
        RemoteImage(type: .url(url)) { error in
            Text(error.localizedDescription)
        } imageView: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } loadingView: {
            Text("Loading ...")
        }
    }
}

struct FolderHeaderView: View {
    @State var folderURL: URL

    var body: some View {
        Text(folderURL.lastPathComponent)
            .font(.headline)
            .padding(.vertical, 5)
    }
}

struct FolderHeaderViewWrapper: View {
    let folderURL: URL?

    var body: some View {
        if let folder = folderURL {
            FolderHeaderView(folderURL: folder)
        }
    }
}

struct AppFoldersView: View {
    @EnvironmentObject var appData: AppData
    @State var selectedItem: String? = nil
    @State private var currentFolder: String = "/"
    @State private var showPlain: Bool = false

    private var groupedFolderEntries: [(UUID, String, [String: [AppEntry]])] {
        let folderOrder = Dictionary(uniqueKeysWithValues: appData.appFolders.enumerated().map { ($0.element.id, $0.offset) })
        
        return appData.appFolders
            .map { folder in
                (folder.id, folder.name, Dictionary(grouping: folder.entries) { entry in
                    let path = entry.appURL.deletingLastPathComponent().path
                    let check = path.replacingOccurrences(of: "^/Users/[^/]+", with: "~", options: .regularExpression)
                    return check
                })
            }
            .sorted { folderOrder[$0.0, default: 0] < folderOrder[$1.0, default: 0] }
    }
    
    var body: some View {
        let _ = symlog.debug("AppFoldersViews")
        VStack {
            let url = URL(string: "https://cdn0.iconfinder.com/data/icons/small-n-flat/24/678084-folder-128.png")!

            Button {
                showPlain.toggle()
            } label: {
                VStack {
                    RemoteImageView(url: url)
                        .frame(width: 32, height: 32)
                    Text("Show Plain")
                }
            }
            .padding(.bottom, 10)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                    ForEach(groupedFolderEntries, id: \.0) { folderId, _, subfolders in
                        ForEach(subfolders.keys.sorted(), id: \.self) { subfolderName in
                            Section(header: Text(subfolderName).font(.title)) {
                                ForEach(subfolders[subfolderName] ?? [], id: \.self) { entry in
                                    AppFolderView(entry: entry)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
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
    }
}

struct AppFoldersViews_Previews: PreviewProvider {
    static var previews: some View {
//        let folders = [Folder(id: 1, name: "Apps", url: URL(fileURLWithPath: "/Users/davec/Applications"))]
        AppFoldersView()
    }
}
