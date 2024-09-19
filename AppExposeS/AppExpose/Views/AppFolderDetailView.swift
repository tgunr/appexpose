//
//  AppFolderDetailView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/19/24.
//

import SwiftUI

struct AppFolderDetailView: View {
    @State var entry: AppEntry
    
    var body: some View {
        Text(entry.name ?? "")
    }
}

#Preview {
    @Previewable @State var entry = AppEntry(withURL: URL(fileURLWithPath: "/Applications/SVG"))
    AppFolderDetailView(entry: entry)
}
