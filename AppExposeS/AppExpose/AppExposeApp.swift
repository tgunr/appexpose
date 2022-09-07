//
//  AppExposeApp.swift
//  AppExpose
//
//  Created by Dave Carlton on 8/21/22.
//

import AppKit
import SwiftUI

class appData: NSObject, ObservableObject {
    static let shared = appData()
    @Published var folders = Array<String>()
    var progress: Progress?
    override init() {
    }
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
//    @EnvironmentObject private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ToolbarView()
            SidebarView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .environmentObject(appData.shared)
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


