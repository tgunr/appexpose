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
        var dirPaths = NSSearchPathForDirectoriesInDomains(.applicationDirectory,
                                                           .systemDomainMask, true)
        if (dirPaths.count > 0) {
            appDirectory = dirPaths[0]
        }
        
        let defaults = UserDefaults.standard
        let debug = defaults.bool(forKey: "debug")
        if (debug) {
            dirPaths = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .userDomainMask, true)
            if (dirPaths.count > 0) {
                appDirectory = dirPaths[0]
            }
        }
        
        appDirectory = appDirectory + "/"
        
        let directory = defaults.string(forKey: "path")
        if ((directory) != nil) {
            appDirectory = directory!
        }
//        myWindowController?.viewController?.url = NSURL.fileURL(withPath: appDirectory)
    }

    func applicationDidResignActive(_ notification: Notification) {
        self.isActive = false
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.isActive = true
    }
}
