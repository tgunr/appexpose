//
//  AppExposeApp.swift
//  AppExpose
//
//  Created by Dave Carlton on 8/21/22.
//

import AppKit
import SwiftUI

class AppData: NSObject, ObservableObject {
    static let shared = AppData()
    var iconSize: Double = 32.0
    @Published var folders = Array<String>()
    @State var bold = true
    @State var remove = false
    @State var selectAll = false
    var progress: Progress?
    override init() {
    }
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var iconSize: Double? = 32.0
    var body: some Scene {
        WindowGroup {
            ToolbarView()
            SidebarView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(AppData.shared)
        }
//        Settings {
//            PreferencesView(model: model)
//        }
//        }.commands {
        // This is optional, but adds menu items for toolbar customization
//            ToolbarCommands()
//        }
    }
}
