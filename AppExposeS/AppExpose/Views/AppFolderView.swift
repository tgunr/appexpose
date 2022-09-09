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
    var folder: String
    @StateObject private var appFolder = AppFolder()

    init(folder: String) {
        self.folder = folder
        //        if let u = URL(string: folder) {
        //            appFolder.model = AppEntry.collect(from: u)
        //        }
    }

    var body: some View {
        Text("\(folder)")
            .onLoad {
                if let u = URL(string: folder) {
                    appFolder.model = AppEntry.collect(from: u)
                }
            }
        List {
            if let m = appFolder.model {
                let e = m.childEntries
                ForEach(e, id: \.self) { entry in
                    if let n = entry.appURL?.absoluteString {
                        Text(n)
                    }
                }
            }
        }
    }
}

struct AppFolderView_Previews: PreviewProvider {
    static var previews: some View {
        AppFolderView(folder: "one")
    }
}
