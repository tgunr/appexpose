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
    @MainActor  static let shared = AppDelegate()

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
        if let savedFolders = SettingsManager.shared.getFolderArray(forKey: "folders") {
            AppData.shared.appFolders = savedFolders
        } else {
            let defaultFolder: Folder = Folder(id: UUID(), name: "Applications", url: URL(fileURLWithPath: "/Applications"), entries: [])
            AppData.shared.appFolders = [defaultFolder]
            SettingsManager.shared.setFolderArray(AppData.shared.appFolders, forKey: "folders")
        }
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        self.isActive = false
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.isActive = true
    }
}
