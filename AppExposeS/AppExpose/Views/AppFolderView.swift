//
//  AppFolderView.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/7/22.
//

import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
    @State private var didLoad = false
    private let action: (() -> Void)?

    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if didLoad == false {
                didLoad = true
                action?()
            }
        }
    }
}

// extension View {
//    func onLoad(perform action: (() -> Void)? = nil) -> some View {
//        modifier(ViewDidLoadModifier(perform: action))
//    }
// }

struct AppFolderView: View {
    let entry: AppEntry
    @Binding var showFilter: ShowFilter
    @Binding var canSelect: Bool
    // var onSelected: (AppEntry) -> Void // new callback

    // @State private var isShowingDetail = false // Add this line

    var body: some View {
        let _ = symlog.entry("AppFolderView entry: \(entry.name ?? "none")")

        // Wrap the content in a NavigationLink
        NavigationLink(value: entry) {
            switch showFilter {
            case .all:
                entryView
            case .exposed:
                if entry.hasMyCustomIcon {
                    entryView
                } else {
                    Text("Not shown: Exposed filter, no custom icon")
                }
            case .unmodified:
                if !entry.hasMyCustomIcon && entry.isFolder && !entry.isApp {
                    entryView
                } else {
                    Text("Not shown: Unmodified filter, conditions not met")
                }
            }
        }
        .contextMenu {
            Button("Show In Finder") {
                NSWorkspace.shared.selectFile(entry.appURL.path, inFileViewerRootedAtPath: "")
            }
            Button("Edit") {
                // Edit the entry
            }
            Button("Delete") {
                // Delete the entry
            }
        }
    }

    var entryView: some View {
        VStack {
            Group {
                if entry.hasMyCustomIcon {
                    Image(nsImage: entry.appImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(nsImage: entry.originalImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            Text(entry.name ?? "none")
                .lineLimit(2)
                .multilineTextAlignment(.center)
            #if DEBUG
                Text(entry.addedDate?.formatted(date: .numeric, time: .omitted) ?? "none")
                    .font(.caption)
            #endif
        }
        #if DEBUG
            .frame(width: 120, height: 64)
        #else
            .frame(width: 64, height: 64)
        #endif
            .border(.blue, width: entry.isSelected ? 1.0 : 0.0)
            .cornerRadius(8.0)
    }
}

struct AppFolderView_PreviewWrapper: View {
    @State private var showFilter: ShowFilter = .all
    @State private var canSelect: Bool = false
    @State private var entry: AppEntry?
    
    var body: some View {
        Group {
            if let entry = entry {
                AppFolderView(entry: entry, showFilter: $showFilter, canSelect: $canSelect)
            } else {
                Text("Loading...")
            }
        }
        .task {
            let entries = await AppEntry.scanApplications(atPath: "/Users/davec/Applications", currentDirectory: nil)
            self.entry = entries.first
        }
    }
}

struct AppFolderView_Previews: PreviewProvider {
    static var previews: some View {
        AppFolderView_PreviewWrapper()
    }
}

        
