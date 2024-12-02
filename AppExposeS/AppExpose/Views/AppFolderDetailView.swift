//
//  AppFolderDetailView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/19/24.

import SwiftUI

// AppFolderDetailView.swift

struct AppFolderDetailView: View {
    @Binding var entry: AppEntry
    @Environment(\.presentationMode) var presentationMode // Add this line

    var body: some View {
        VStack {
            HStack { // Add this HStack
                Spacer()
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
            
            Text(entry.name ?? "")
                .font(.title)
            ScrollView {
                List {
                    ForEach(entry.children, id: \.self) { child in
                        let _ = symlog.value("AppFolderDetailView• child: \(child.name ?? "none")")
                        HStack {
                            Image(nsImage: child.appImage ?? NSImage())
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text(child.name ?? "")
                        }
                    }
                }
            }

        }
    }
}

#Preview {
    @Previewable @State var entry = AppEntry(withURL: URL(fileURLWithPath: "/Users/davec/Applications/WebApps"))
    AppFolderDetailView(entry: $entry)
}
