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
    @Binding var entry: AppEntry
    @Binding var showFilter: ShowFilter
    @Binding var canSelect: Bool
    var onSelected: (AppEntry) -> Void // new callback

    @State private var pushed = false
    // @State private var isShowingDetail = false // Add this line

    var link: some View {
        Button(action: {
            onSelected(entry)
            // isShowingDetail = true // Add this line
        }) {
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
//            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8.0)
        }
        // .sheet(isPresented: $isShowingDetail) { // Add this modifier
        //     AppFolderDetailView(entry: $entry)
        // }
    }

    var body: some View {
        let _ = symlog.entry("AppFolderView entry: \(entry.name ?? "none")")


        VStack {
            Text("Debug: ShowFilter = \(showFilter.rawValue)")
            Text("Debug: HasMyCustomIcon = \(entry.hasMyCustomIcon)")
            Text("Debug: IsFolder = \(entry.isFolder)")
            Text("Debug: IsApp = \(entry.isApp)")

            switch showFilter {
            case .all:
                link
            case .exposed:
                if entry.hasMyCustomIcon {
                    link
                } else {
                    Text("Not shown: Exposed filter, no custom icon")
                }
            case .unmodified:
                if !entry.hasMyCustomIcon && entry.isFolder && !entry.isApp {
                    link
                } else {
                    Text("Not shown: Unmodified filter, conditions not met")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var showFilter: ShowFilter = .all
    @Previewable @State var canSelect: Bool = false
    @Previewable @State var entry = AppEntry(withURL: URL(string: "/Applications/SVG")!)
    AppFolderView(entry: $entry, showFilter: $showFilter, canSelect: $canSelect, onSelected: {_ in})
}

struct AppFolderDetailViewT: View {
    let entry: AppEntry

    var body: some View {
        VStack {
            Text("Folder Details")
                .font(.title)
            Text("Name: \(entry.name ?? "Unknown")")
            // Add more details as needed
        }
    }
}
