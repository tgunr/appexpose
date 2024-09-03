//
//  AppFoldersViews.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import SwiftUI

struct AppFoldersViews: View {
    @EnvironmentObject var appData: AppData
    @State var appEntry: AppEntry?
    @State var selectedItem: String? = nil
    
//    init() {
//        let appsURL = URL(fileURLWithPath: "/Applications")
//        self.appEntry = AppEntry(url: appsURL)
//    }
    
    var body: some View {
        let _ = symlog.debug("AppFoldersViews")
        VStack {
            if appEntry == nil {
                ProgressView()
            } else {
                if appEntry!.childEntries.isEmpty {
                    Text("No Applications Found")
                } else {
                    Text("Applications")
                        .font(.title)
                        .padding(.bottom, 5)
                    List {
                        ForEach(appEntry!.childEntries, id: \.self) {
                            let fname = $0.name
                            NavigationLink( destination: AppFolderView(folder: fname!)) {
                                Label(fname!, systemImage: "folder")
                            }
                        }
                    }
                }
            }
        }
        .task {
            symlog.info("Fetching Apps")
            let appsURL = URL(fileURLWithPath: "/Applications")
            DispatchQueue.main.async {
                self.appEntry = AppEntry(url: appsURL)
                symlog.value("AppEntry created with \(self.appEntry?.childEntries.count ?? 0) child entries")
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
        AppFoldersViews()
    }
}
