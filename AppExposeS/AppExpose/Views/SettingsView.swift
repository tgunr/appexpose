//
//  SettingsView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/6/22.
//

import SwiftUI

// struct AppFolder: Identifiable, Hashable {
//    let id = UUID()
//    let path: String
// }

struct SettingsView: View {
    @AppStorage("itemsString") var appFolders = [""]
    @State private var fileURL: URL?

    var body: some View {
//        var folders = appFolders.map({ AppFolder(path: $0) })
//        NavigationStack {
        let _ = symlog.info("SettingsView")
        ContentView()
        Form {
            Section(header: Text("Application Folder")) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Location:")
                    DirectorySelectorView(url: self.$fileURL)
                        .onChange(of: fileURL) { oldValue, newValue in
                            update(url: newValue)
                        }
                }
            }
        }
        .onSubmit {
            self.update(url: fileURL)
        }
//        }
    }

    func update(url: URL?) {
        if let aURL = url {
//            let thePrefix = "file://"
//            let path = aURL.absoluteString.replacingOccurrences(of: thePrefix, with: "")
            appFolders.append(aURL.absoluteString)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
