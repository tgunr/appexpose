//
//  SubfolderView 2.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/22/24.

import SwiftUI

@MainActor
class Preview: ObservableObject {
    @Published var appData = AppData()
    @Published var entries: [AppEntry] = [] // Initialize as an empty array
    @Published var folder1: Folder
    @Published var folder2: Folder

    @Published var showFilter = ShowFilter.all
    @Published var sortOption = SortOption.name

    init() {
        folder1 = Folder(id: UUID(), name: "Apps", url: URL(fileURLWithPath: "/Users/davec/Applications"), entries: [])
        folder2 = Folder(id: UUID(), name: "Apps", url: URL(fileURLWithPath: "/Applications"), entries: [])
        appData.appFolders = [folder1, folder2]
        
        // Use Task to perform async operation
        Task {
            await loadEntries()
        }
    }
    
    func loadEntries() async {
        entries = await AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
        // Update folders with scanned entries
        folder1.entries = entries
        folder2.entries = entries
    }
}

// Use this PreviewWrapper to create the preview
struct PreviewWrapper: View {
    @StateObject private var preview = Preview()
    
    var body: some View {
        Text("Preview loaded with \(preview.entries.count) entries")
    }
}

#Preview {
    PreviewWrapper()
}
