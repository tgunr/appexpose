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

extension View {
    func onLoad(perform action: (() -> Void)? = nil) -> some View {
        modifier(ViewDidLoadModifier(perform: action))
    }
}

struct AppFolderView: View {
    @ObservedObject var entry: AppEntry
    @Binding var showOptions: ShowOption

    var body: some View {
        let _ = symlog.entry("AppFolderView entry: \(entry.name ?? "none")")
        VStack {
            if let appImage = entry.appImage {
                Image(nsImage: appImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
            } else {
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
            }
            Text(entry.name ?? "none")
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
        .background(Color.blue.opacity(0.1))

//        VStack {
//            if let appImage = entry.appImage {
//                if entry.name == "!NCViewer" {
//                    let _ = symlog.info("AppFolderView appImage: NCViewer")
//                }
//                Image(nsImage: appImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 32, height: 32)
//            } else {
//                if entry.name == "!NCViewer" {
//                    let _ = symlog.info("AppFolderView folder")
//                }
//                Image(systemName: "folder")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 32, height: 32)
//            }
//            Text(entry.name ?? "none")
//                .lineLimit(2)
//                .multilineTextAlignment(.center)
//        }
//        .frame(width: 100, height: 100)
        .padding()
        .cornerRadius(10)
        .background(Color.gray)
        .border(Color.black, width: 1)
    }
}

struct AppFolderView_Previews: PreviewProvider {
    @State var showOptions: ShowOption = .all

    static var previews: some View {
        let entry = AppEntry(withURL: URL(string: "/Applications/SVG")!)
        AppFolderView(entry: entry, showOptions: .constant(.all)
        )
    }
}
