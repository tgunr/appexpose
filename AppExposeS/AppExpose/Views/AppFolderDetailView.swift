//
//  AppFolderDetailView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/19/24.
//

import SwiftUI

struct AppFolderDetailView: View {
    @Binding var isShowingSheet: Bool
    @State var entry: AppEntry
    
    var body: some View {
        Text(entry.name ?? "")
            .onTapGesture {
                isShowingSheet = false
            }
    }
}

#Preview {
    @Previewable @State var entry = AppEntry(withURL: URL(fileURLWithPath: "/Applications/SVG"))
    AppFolderDetailView(isShowingSheet: .constant(true), entry: entry)
}
