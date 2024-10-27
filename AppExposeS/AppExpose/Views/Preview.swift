//
//  SubfolderView 2.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.
//

import SwiftUI

@MainActor
struct Preview {
    var appData = AppData()
    var entries = AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
    var folder: Folder

    init() {
        folder = Folder(id: UUID(), name: "Apps", url: URL(fileURLWithPath: "/Users/davec/Applications"), entries: entries)
        appData.appFolders = [folder]
    }

    @State var showOptions = ShowFilter.all
    @State var sortOption = SortOption.name
}
