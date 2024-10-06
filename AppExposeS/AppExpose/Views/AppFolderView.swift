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
    @State var entry: AppEntry
    @Binding var showOptions: ShowOption

    var body: some View {
        VStack {
            if let appImage = entry.appImage {
                Image(nsImage: appImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } else {
                Image(systemName: "folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            }
            Text(entry.name ?? "none")
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 150, height: 100)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
