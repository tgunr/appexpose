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

    var link: some View {
        Button(action: {
            onSelected(entry)
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
    }

    var body: some View {
        let _ = symlog.entry("AppFolderView entry: \(entry.name ?? "none")")

        switch showFilter {
        case .all:
            link
        case .exposed:
            if entry.hasMyCustomIcon {
                link
            }
        case .unmodified:
            if !entry.hasMyCustomIcon && entry.isFolder && !entry.isApp {
                link
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
