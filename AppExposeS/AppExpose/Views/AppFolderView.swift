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

struct AppFolderView1: View {
    @State var entry: AppEntry
    @StateObject private var appFolder = AppFolder()
    @EnvironmentObject var appData: AppData

//    init(folder: String) {
//        self.folder = folder
//        //        if let u = URL(string: folder) {
//        //            appFolder.model = AppEntry.collect(from: u)
//        //        }
//    }

    var body: some View {
        Text("\(entry.name ?? "")")
        List {
            if let m = appFolder.model {
                let entries = m.children
                ForEach(entries, id: \.self) { entry in
                    let entryURL = entry.appURL.absoluteString
                    Text(entryURL)

                    if let oImage = entry.originalImage {
                        let w = appData.iconSize
                        let wi = Int(w)
                        let h = appData.iconSize
                        let hi = Int(h)
                        var imageRect = CGRect(x: 0, y: 0, width: wi, height: hi)
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
        AppFolderView(entry: AppEntry(withURL: URL(string: "/Applications/SVG")!)
        )
    }
}
