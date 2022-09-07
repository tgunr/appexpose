//
//  AppFolderView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import SwiftUI

struct AppFolderView: View {
    var folder: String
    @State private var appFolder: [AppEntry]?
        
    init(folder: String) {
        self.folder = folder
        let u = URL(string: folder)
        appFolder = AppEntry.collect(from: u!)
    }
    
    var body: some View {
        Text("\(folder)")
    }
}

struct AppFolderView_Previews: PreviewProvider {
    static var previews: some View {
        AppFolderView(folder: "one")
    }
}
