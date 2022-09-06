//
//  AppDelegate.swift
//  AppExposeS
//
//  Created by Dave Carlton on 8/23/22.
//

import Foundation
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    @Published var isActive: Bool = true
    
    func applicationDidResignActive(_ notification: Notification) {
        self.isActive = false
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.isActive = true
    }
}
