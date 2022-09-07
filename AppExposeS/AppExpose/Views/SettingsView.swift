//
//  SettingsView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import SwiftUI

struct AppFolder: Identifiable, Hashable {
    let id = UUID()
    let path: String
}

struct SettingsView: View {
    @AppStorage("itemsString") var appFolders = [""]
    @State private var fileURL: URL?

    var body: some View {
//        var folders = appFolders.map({ AppFolder(path: $0) })
        NavigationStack {
            Form {
                Section(header: Text("Application Folder"), content: ({
                    HStack(alignment: .firstTextBaseline) {
                       Text("Location:")
                       DirectorySelectorView(url: self.$fileURL)
                   }
                }))
            }
        }
    }
}

struct SettingsView1: View {
    @AppStorage("itemsString") var appFolders = [""]
    @State private var location: String = ""

    var body: some View {
        VStack {
            Text("appFolders: \(String(describing: appFolders))")
//            ForEach(appFolders, content: loc in {
//                Text("loc: \(loc)")
//            })
//            List(appFolders) { loc in
//                Text("loc: \(loc)")
//            }
            Form {
                TextField("Location", text: $location, prompt: Text("enter application folder"))
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
