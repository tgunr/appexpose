//
//  AppFolderDetailView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/19/24.
//

import SwiftUI

// AppFolderDetailView.swift

struct AppFolderDetailView: View {
    @Binding var entry: AppEntry
    @Binding var showDetailView: Bool

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    showDetailView = false
                }
                .padding()
            }
            
            Text(entry.name ?? "")
                .font(.title)
            ScrollView {
                LazyVStack {
                    ForEach(entry.children) { child in
                        let _ = symlog.value("AppFolderDetailView• child: \(child.name ?? "none")")
                        HStack {
                            Image(nsImage: child.appImage ?? NSImage())
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text(child.name ?? "")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle(entry.name ?? "")
    }
}

#Preview {
    @Previewable @State var entry = AppEntry(withURL: URL(fileURLWithPath: "/Users/davec/Applications/WebApps"))
    @Previewable @State var showDetailView: Bool = true

    AppFolderDetailView(entry: $entry, showDetailView: $showDetailView)
}
