//
//  AppDelegate.swift
//  AppExposeS
//
//  Created by Dave Carlton on 8/23/22.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    // create a shared instance of the AppDelegate
    static let shared = AppDelegate()

    @Published var isActive: Bool = true

    var iconCollection: NSCollectionView?
    var appBrowser: NSBrowser?
    var iconAppearence: NSSegmentedControl?
    
    var appDirectory: String = "/Applications"
    var dirItems: [String] = []
    var dirPath = ""
    var rootEntry: AppEntry?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let dirPaths = SettingsManager.shared.getStringArray(forKey: "folders") {
            AppData.shared.folders = dirPaths
        } else {
            AppData.shared.folders = ["/Applications"]
            SettingsManager.shared.setStringArray(AppData.shared.folders, forKey: "folders")
        }
    }

    func applicationDidResignActive(_ notification: Notification) {
        self.isActive = false
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.isActive = true
    }
}
