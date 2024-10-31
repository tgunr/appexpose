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
    @ObservedObject var entry: EntryFilterData
    @Binding var showFilter: ShowFilter

    var body: some View {
        let _ = symlog.entry("AppFolderView entry: \(entry.name ?? "none")")

        let extractedExpr: VStack<some View> = VStack {
            Button(action: {
                entry.isSelected.toggle()
                symlog.info("Selected \(entry.isSelected ? "true" : "false")")
            }, label: {
                VStack {
                    Group {
                        if entry.hasMyCustomIcon {
                            if entry.name == "!NCViewer" {
                                let _ = symlog.info("AppFolderView appImage: NCViewer")
                            }
                            Image(nsImage: entry.appImage!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            if entry.name == "!NCViewer" {
                                let _ = symlog.info("AppFolderView folder")
                            }
                            Image(nsImage: entry.originalImage!)
//                            Image(systemName: "folder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                    .padding(3)
                    Text(entry.name ?? "none")
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .frame(width: 64, height: 64)
                .border(.blue, width: entry.isSelected ? 3.0 : 0.0)
                .background(Color(NSColor.windowBackgroundColor))
                .cornerRadius(8.0)
            })
            .buttonStyle(.bordered)
        }
        switch showFilter {
        case .all:
            extractedExpr
        case .exposed:
            if entry.hasMyCustomIcon {
                extractedExpr
            }
        case .unmodified:
            if !entry.hasMyCustomIcon && entry.isFolder && !entry.isApp {
                extractedExpr
            }
        }
    }
}

struct AppFolderView_Previews: PreviewProvider {
    @State var showFilter: ShowFilter = .all

    static var previews: some View {
        let entry = AppEntry(withURL: URL(string: "/Applications/SVG")!)
        AppFolderView(entry: entry, showFilter: .constant(.unmodified)
        )
    }
}
