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
    @EnvironmentObject var appData: AppData
    
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
                let entries = m.childEntries
                ForEach(entries, id: \.self) { entry in
                    if let entryURL = entry.appURL?.absoluteString {
                        Text(entryURL)
                    }
                    if let oImage = entry.originalImage {
                        let w = appData.$iconSize
                        let wi = Int(w)
                        let h = appData.$iconSize

                        var imageRect = CGRect(x: 0, y: 0, width: w, height: h)
                        let imageRef = oImage.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
                        Image(imageRef!,
                              scale: 1.0,
                              orientation: .up,
                              label: Text("Locomotive"))
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
