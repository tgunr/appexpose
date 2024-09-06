//
//  AppFoldersViews.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import SwiftUI

struct AppFoldersViews: View {
    @EnvironmentObject var appData: AppData
    @State var appEntries: [AppEntry] = []
    @State var selectedItem: String? = nil

//    init() {
//        let appsURL = URL(fileURLWithPath: "/Applications")
//        self.appEntry = AppEntry(url: appsURL)
//    }

    var body: some View {
        let _ = symlog.debug("AppFoldersViews")
        VStack {
            if appEntries.isEmpty {
                ProgressView()
            } else {
                if appEntries.isEmpty {
                    Text("No Applications Found")
                } else {
                    Text("Applications")
                        .font(.title)
                        .padding(.bottom, 5)
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                            ForEach(appEntries, id: \.self) { entry in
                                let fname = entry.name
                                NavigationLink(destination: AppFolderView(folder: fname!)) {
                                    VStack {
                                        if let appImage = entry.appImage {
                                            Image(nsImage: appImage)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 50, height: 50)
                                        } else {
                                            Image(systemName: "folder")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 50, height: 50)
                                        }
                                        Text(fname!)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(width: 150, height: 100)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding()
                    }
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
        AppFoldersViews()
    }
}
