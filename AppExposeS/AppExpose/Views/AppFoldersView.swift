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
    @ObservedObject var appData = AppData.shared
    @State var appEntries: [AppEntry] = []
    @State var selectedItem: String? = nil
    @State private var currentFolder: String = "/"
    @State private var showPlain: Bool = false
    
    var body: some View {
        let _ = symlog.debug("AppFoldersViews")
        VStack {
            if appEntries.isEmpty {
                ProgressView("Gathering Apps")
            } else {
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
                        let groupedEntries = Dictionary(grouping: appEntries) { entry in
                            let path = entry.appURL.deletingLastPathComponent().path
                            return path.replacingOccurrences(of: "^/Users/[^/]+", with: "~", options: .regularExpression)
                        }
                        ForEach(groupedEntries.keys.sorted(), id: \.self) { folderName in
                            Section(header: Text(folderName).font(.title)) {
                                ForEach(groupedEntries[folderName] ?? [], id: \.self) { entry in
                                    AppFolderView(entry: entry)
                                }
                            }
                        }
                    }
                }
                .padding()
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
        for folder in appData.appFolders {
            let entries = AppEntry.scanApplications(atPath: folder.url.path, currentDirectory: nil)
            DispatchQueue.main.async {
                appEntries.append(contentsOf: entries)
            }
        }
        symlog.value("AppEntry created with \(appEntries.count) child entries")
    }
}



struct AppFoldersViews_Previews: PreviewProvider {
    static var previews: some View {
//        let folders = [Folder(id: 1, name: "Apps", url: URL(fileURLWithPath: "/Users/davec/Applications"))]
        AppFoldersView()
    }
}
