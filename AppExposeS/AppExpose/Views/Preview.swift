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
    var folder1: Folder
    var folder2: Folder

    init() {
        folder1 = Folder(id: UUID(), name: "Apps", url: URL(fileURLWithPath: "/Users/davec/Applications"), entries: entries)
        folder2 = Folder(id: UUID(), name: "Apps", url: URL(fileURLWithPath: "/Applications"), entries: entries)
        appData.appFolders = [folder1, folder2]
    }

    @State var showFilter = ShowFilter.all
    @State var sortOption = SortOption.name
}
