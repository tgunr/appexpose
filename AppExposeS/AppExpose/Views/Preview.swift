//
//  SubfolderView 2.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.
//

import SwiftUI

struct Preview {
    var data = AppData()
    var entries = AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
    var folder: Folder

    init() {
        folder = Folder(id: UUID(), name: "Apps", url: URL(fileURLWithPath: "/Users/davec/Applications"), entries: entries)
        data.appFolders = [folder]
    }

    let mockShowOptions = ShowOption.all
    let mockSortOption = SortOption.name
}
