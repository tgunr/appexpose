//
//  AppDelegate.swift
//  AppExposeS
//
//  Created by Dave Carlton on 8/23/22.
//

import Foundation
import AppKit
import SLogMacro

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
        if let dirPaths = SettingsManager.shared.getFolderArray(forKey: "folders") {
            AppData.shared.folders = dirPaths
        } else {
            let defaultFolder: Folder = Folder(id: 0, name: "Applications", url: URL(fileURLWithPath: "/Applications"))
            AppData.shared.folders = [defaultFolder]
            SettingsManager.shared.setFolderArray(AppData.shared.folders, forKey: "folders")
        }
    }

    func applicationDidResignActive(_ notification: Notification) {
        self.isActive = false
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.isActive = true
    }
}
