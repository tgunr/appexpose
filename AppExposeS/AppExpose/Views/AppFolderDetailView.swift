//
//  AppFolderDetailView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/19/24.
//

import SwiftUI

struct AppFolderDetailView: View {
    @Binding var entry: AppEntry?
    
    var body: some View {
        if let entry = entry {
            Text(entry.name ?? "")
                .frame(width: 200, height: 200)
        } else {
            Text("No Entry Selected")
                .frame(width: 200, height: 200)
        }
    }
}

#Preview {
    @Previewable @State var entry = AppEntry(withURL: URL(fileURLWithPath: "/Applications/SVG"))
    AppFolderDetailView(entry: Binding(get: { entry }, set: { entry = $0! } ))
}
