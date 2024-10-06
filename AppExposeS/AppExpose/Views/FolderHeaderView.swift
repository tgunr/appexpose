//
//  FolderHeaderView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 10/6/24.
//

import SwiftUI

struct FolderHeaderView: View {
    @State var folderURL: URL

    var body: some View {
        Text(folderURL.lastPathComponent)
            .font(.headline)
            .padding(.vertical, 5)
    }
}

struct FolderHeaderViewWrapper: View {
    let folderURL: URL?

    var body: some View {
        if let folder = folderURL {
            FolderHeaderView(folderURL: folder)
        }
    }
}
