//  Converted to Swift 5.6.1 by Swiftify v5.6.22657 - https://swiftify.com/
//
//  AppDelegate.swift
//  AppExpose
//
//  Created by Dave Carlton on 1/5/12.
//  Copyright (c) 2012 PolyMicro Systems. All rights reserved.
//

import Cocoa
import Foundation

@objcMembers
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var myAuthorizationRef: AuthorizationRef?
    var appDirectory: String = ""
    
    private var dirItems: [AnyHashable] = []
    private var dirPath: String = ""
    private var rootEntry: AppEntry?

    @IBOutlet var myWindowController: MyWindowController!
    @IBOutlet var window: NSWindow!
    @IBOutlet var iconCollection: NSCollectionView!
    @IBOutlet var appBrowser: NSBrowser!
    @IBOutlet var iconAppearance: NSSegmentedControl!

    static let shared = AppDelegate()

    override init() {
        super.init()
        rootEntry = .root()
    }

    func setAppDirectory() {
        //    OSStatus myStatus;
        //    myStatus = AuthorizationCreate (NULL, kAuthorizationEmptyEnvironment,
        //                                    kAuthorizationFlagDefaults, &myAuthorizationRef);
        //    AuthorizationFlags myFlags;
        //    myFlags = kAuthorizationFlagDefaults |
        //    kAuthorizationFlagExtendRights |
        //    kAuthorizationFlagInteractionAllowed |
        //    kAuthorizationFlagPreAuthorize;
        
        let paths: [String] = FileManager.default.urls(for: .applicationDirectory, in: .systemDomainMask).map(\.path)
        appDirectory = paths[0]
        if paths.count > 0 {
            appDirectory = paths[0]
        }
        appDirectory = appDirectory + "/"
        let defaults: UserDefaults? = UserDefaults.standard
        let debug: Bool = defaults?.bool(forKey: "debug") ?? false
        if debug {
            PMLOG_SetVerbose(PMLogLevelDebug);
        }
        let directory: String? = defaults?.string(forKey: "path")
        if let directory = directory {
            appDirectory = directory
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setAppDirectory()
        myWindowController.viewController.url = URL(fileURLWithPath: appDirectory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func openReadMe(_ sender: Any) {
        let fullPath: String? = Bundle.main.path(forResource: "ReadMe", ofType: "txt")
        NSWorkspace.shared.openFile(fullPath ?? "")
    }

    // MARK: NSBrowser Data Source Methods

    func rootItem(for browser: NSBrowser) -> Any? {
        return rootEntry
    }

//    func browser(_ browser: NSBrowser, numberOfChildrenOfItem item: Any?) -> Int {
//        return (item as? AppEntry)?.childEntries().count() ?? 0
//    }
//
//    func browser(_ browser: NSBrowser, child index: Int, ofItem item: Any?) -> Any {
//        return ((item as? AppEntry)?.childEntries()[index])!
//    }
//
//    func browser(_ browser: NSBrowser, isLeafItem item: Any?) -> Bool {
//        return (item as? AppEntry)?.isLeaf() ?? false
//    }
//
//    func browser(_ browser: NSBrowser, objectValueForItem item: Any?) -> Any? {
//        return (item as? AppEntry)?.name()
//    }
//
    func selectionChanged() {
        myWindowController.selectionChanged()
    }
}
