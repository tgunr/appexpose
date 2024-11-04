//
//  AppFolderDetailView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/19/24.
//

import SwiftUI

// AppFolderDetailView.swift

struct AppFolderDetailView: View {
    @Binding var entry: AppEntry?

    var body: some View {
        if let entry = entry {
            VStack {
                Text(entry.name ?? "")
                        .font(.title)
                List {
                    ForEach(entry.children, id: \.self) { child in
                        HStack {
                            Image(nsImage: child.appImage ?? NSImage())
                                    .resizable()
                                    .frame(width: 32, height: 32)
                            Text(child.name ?? "")
                        }
                    }
                }
            }
        } else {
            Text("No Entry Selected")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .lineLimit(2)
                    .background(Color.red.opacity(0.2))
        }
    }
}

#Preview {
    @Previewable @State var entry = AppEntry(withURL: URL(fileURLWithPath: "/Applications/SVG"))
    AppFolderDetailView(entry: Binding(get: { entry }, set: { entry = $0! } ))
}
