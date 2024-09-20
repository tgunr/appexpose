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

let symlog = createLogger("app", subsystem: logid, subsystemColor: .black, categories: logCategories)
let uilog = createLogger("uiview", subsystem: logid, subsystemColor: .violet, categories: logCategories)
let storelog = createLogger("store", subsystem: logid, subsystemColor: .blue, categories: logCategories)

class AppData: NSObject, ObservableObject {
    static let shared = AppData()
    var iconSize: Double = 32.0
    @Published var folders = Array<Folder>()
    @State var bold = true
    @State var remove = false
    @State var selectAll = false
}

@main
struct MyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .defaultAppStorage(UserDefaults(suiteName: "net.polymicro.appexpose")!)
        }
        MenuBarExtra("My Menu", systemImage: "gear") {
            SettingsView()
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environmentObject(AppData.shared)
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
