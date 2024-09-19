//
//  AppFoldersViews.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import SwiftUI

struct AppFoldersView: View {
    @EnvironmentObject var appData: AppData
    @State var appEntries: [AppEntry] = []
    @State var selectedItem: String? = nil
    @State private var showPlain: Bool = false
//    init() {
//        let appsURL = URL(fileURLWithPath: "/Applications")
//        self.appEntry = AppEntry(url: appsURL)
//    }

    var body: some View {
        let _ = symlog.debug("AppFoldersViews")
        VStack {
            if appEntries.isEmpty {
                Text("No Applications Found")
            } else {
                Button("Plain", action: ({
                    showPlain.toggle()
                }))
                Text("Applications")
                    .font(.title)
                    .padding(.bottom, 5)
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(appEntries, id: \.self) { entry in
                            if showPlain {
                                if entry.isFolder && !entry.hasCustomIcon && !entry.isApp {
                                    AppFolderView(entry: entry)
                                }
                            } else {
                                AppFolderView(entry: entry)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            symlog.info("Fetching Apps")
//            let appsURL = URL(fileURLWithPath: "/Applications")
            let appsPath = "/Applications"
            DispatchQueue.main.async {
                let app = AppEntry(name: appsPath)
                appEntries = app.scanApplications(atPath: appsPath, currentDirectory: nil)
                symlog.value("AppEntry created with \(self.appEntries.count) child entries")
            }
        }
//        .onDeleteCommand(perform: ({
//            if
//                let sel = self.selectedItem,
//                let idx = self.appEntry.childEntries.firstIndex(of: sel) {
//                print("delete: \(sel)")
//                self.appFolders.remove(at: idx)
//            }
//        }))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: selectedItem)
    }
}

struct AppFoldersViews_Previews: PreviewProvider {
    static var previews: some View {
        AppFoldersView()
    }
}
