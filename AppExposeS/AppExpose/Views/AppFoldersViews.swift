//
//  AppFoldersViews.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import SwiftUI

struct AppFoldersViews: View {
    @AppStorage("itemsString") var appFolders = [""]
    @State var selectedItem: String? = nil
    var body: some View {
        ForEach(appFolders, id: \.self) {
            let fname = $0
            NavigationLink( destination: AppFolderView(folder: fname)) {
                Label(fname, systemImage: "folder")
            }
        }
        .onDeleteCommand(perform: ({
            if
                let sel = self.selectedItem,
                let idx = self.appFolders.firstIndex(of: sel) {
                print("delete: \(sel)")
                self.appFolders.remove(at: idx)
            }
        }))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.default, value: selectedItem)
    }
}

struct AppFoldersViews_Previews: PreviewProvider {
    static var previews: some View {
        AppFoldersViews()
    }
}
