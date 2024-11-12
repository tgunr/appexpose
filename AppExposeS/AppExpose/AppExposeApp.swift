//
//  AppExposeApp.swift
//  AppExpose
//
//  Created by Dave Carlton on 8/21/22.
//

import AppKit
import OSLog
import SwiftUI

let logid = "appexpose"
let logCategories: [String: OSLog.logColor] = [
    "entry": .black,
    "appear": .white,
    "log": .brown,
    "value": .violet,
    "info": .blue,
    "notice": .green,
    "change": .yellow,
    "warning": .orange,
    "error": .red,
]

@MainActor let symlog = createLogger("app", subsystem: logid, subsystemColor: .black, categories: logCategories)
@MainActor let uilog = createLogger("uiview", subsystem: logid, subsystemColor: .violet, categories: logCategories)
@MainActor let storelog = createLogger("store", subsystem: logid, subsystemColor: .blue, categories: logCategories)


class AppData: NSObject, ObservableObject {
    @MainActor static let shared = AppData()
    var iconSize: Double = 32.0
    @Published var appFolders: [Folder] = []
    @Published var bold = true
    @Published var remove = false
    @Published var selectAll = false
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appData = AppData.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .defaultAppStorage(UserDefaults(suiteName: "net.polymicro.appexpose")!)
        }
        MenuBarExtra("My Menu", systemImage: "gear") {
            SettingsView()
                .environmentObject(appData)
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .menuBarExtraStyle(.automatic)
//        Settings {
//            PreferencesView(model: model)
//        }
//        }.commands {
        // This is optional, but adds menu items for toolbar customization
//            ToolbarCommands()
//        }
    }
}
