//
//  ContentView.swift
//  AppExpose
//
//  Created by Dave Carlton on 8/21/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("title") var currentShortcutTitle: String?
    //    @AppStorage("appFolders") var appFolders: [String]
    
    @State private var val: Double = 0.7
    @State private var bold = true
    @State private var italic = false
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                Text("Application Folders")
                List {
                    Text("Folder")
                    Text("Folder")
                    Text("Folder")
                    Text("Folder")
                    Text("Folder")
                    Text("Folder")
                    Button(action: { connect() }) {
                        Text("Done", comment: "Button title to dismiss rewards sheet")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { connect() }) {
                        Text("Done", comment: "Button title to dismiss rewards sheet")
                    }
                }
            }
            .navigationTitle("AppExpose")
        }
    }
    
    func connect() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
