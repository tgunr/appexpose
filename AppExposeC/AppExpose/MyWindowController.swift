//
//  MyWindowController.swift
//  AppExposeC
//
//  Created by Dave Carlton on 9/2/22.
//

import Foundation

/*
     File: MyWindowController.h
 Abstract: This sample's main window controller object.

  Version: 1.2

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2011 Apple Inc. All Rights Reserved.

 */

import Cocoa

//  Converted to Swift 5.6.1 by Swiftify v5.6.22657 - https://swiftify.com/
/*
     File: MyWindowController.m
 Abstract: This sample's main window controller object.

  Version: 1.2

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2011 Apple Inc. All Rights Reserved.

 */

import Cocoa
import Foundation
import SceneKit

@objcMembers
class MyWindowController: NSWindowController {
    @IBOutlet var myTargetView: NSView!
    @IBOutlet var selectionField: NSTextField!
    var viewController: MyViewController?
    @IBOutlet var applyButton: NSButton!
    @IBOutlet var removeButton: NSButton!
    @IBOutlet var selectAllButton: NSButton!
    @IBOutlet var iconView: NSImageView!
    @IBOutlet var iconsView: NSCollectionView!
    @IBOutlet var appearanceControl: NSSegmentedControl!
    @IBOutlet var zoomSlider: NSSlider!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var restartFinder: NSToolbarItem!
    var finder: NSRunningApplication?
    @IBOutlet var selectAllToolBarItem: NSToolbarItem!
    @IBOutlet weak var refreshWindow: NSToolbarItem!
    
    override func awakeFromNib() {
        window?.setAutorecalculatesContentBorderThickness(true, for: .minY)
        window?.setContentBorderThickness(30, for: .minY)
        
        // load our nib that contains the collection view
        willChangeValue(forKey: "viewController")
        viewController = MyViewController(nibName: "Collection", bundle: nil)
        didChangeValue(forKey: "viewController")
        
        myTargetView.addSubview(viewController!.view)
        
        // make sure we resize the viewController's view to match its super view
        viewController?.view.frame = myTargetView.bounds
        //        let mode = SCNParticleSortingMode.none.rawValue.
        //        viewController.sortingMode = (UInt)mode
        AppDelegate.shared.windowController = self
        applyButton.isEnabled = false
        removeButton.isEnabled = false
        
    }
    
    //-(void)showBeforeAppearance {
    //    [viewController showBeforeAppearance];
    //    [applyButton setEnabled:NO];
    //    [removeButton setEnabled:NO];
    //}
    //
    //-(void)showAfterAppearance {
    //    [viewController showAfterAppearance];
    //}
    //
    @IBAction func changeAppearance(_ sender: NSSegmentedControl) {
        let segment: Int = sender.selectedSegment
        switch segment {
        case 0:
            viewController!.showBeforeAppearance()
            applyButton.state = NSControl.StateValue.off
            removeButton.state = NSControl.StateValue.off
            selectAllButton.state = NSControl.StateValue.off
        case 1:
            viewController!.showAfterAppearance()
            selectAllButton.state = NSControl.StateValue.on
        default:
            break
        }
    }
    
    @IBAction func applyIcons(_ sender: Any) {
        viewController!.applyIcons()
    }
    
    @IBAction func removeIcons(_ sender: Any) {
        viewController!.removeIcons()
    }
    
    func setSelectAllLabel() {
        let entries = viewController!.selectedIcons()
        let numberSelected: Int = entries!.count
        let numberOfCollection: Int = viewController!.contentArray.count
        if numberSelected == numberOfCollection {
            selectAllToolBarItem.label = "Select None"
        } else {
            selectAllToolBarItem.label = "Select All"
        }
    }
    
    @IBAction override func selectAll(_ sender: Any?) {
        let label: String = selectAllToolBarItem.label
        if label == "Select All" {
            selectAllToolBarItem.label = "Select None"
            viewController!.selectAll(sender)
        } else {
            selectAllToolBarItem.label = "Select All"
            viewController!.selectNone(sender)
        }
        selectionChanged()
    }
    
    func selectionChanged() {
        let segment: Int = appearanceControl.selectedSegment
        switch segment {
        case 0:
            applyButton.state = NSControl.StateValue.off
            removeButton.state = NSControl.StateValue.off
            selectAllButton.state = NSControl.StateValue.off
        case 1:
            let entries = viewController!.selectedIcons()
            let numberEntries: Int = entries!.count
            if numberEntries != 0 {
                applyButton.state = NSControl.StateValue.on
                removeButton.state = NSControl.StateValue.on
            } else {
                applyButton.state = NSControl.StateValue.off
                removeButton.state = NSControl.StateValue.off
            }
            setSelectAllLabel()
        default:
            break
        }
        
    }
    
    @IBAction func zoomChanged(_ sender: Any) {
        let value = zoomSlider.intValue
        //    int scales[] = { 32, 64, 128, 256, 512, 1024 } ;
        //    int scale = scales[value];
        //        PMLOG_DEBUG("zoom: %f", CGFloat(value))
        viewController!.zoomChanged(CGFloat(value))
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "isTerminated" {
            NSWorkspace.shared.launchApplication(withBundleIdentifier: "com.apple.finder", options: .default, additionalEventParamDescriptor: nil, launchIdentifier: nil)
            self.removeObserver(self, forKeyPath: "isTerminated")
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    @IBAction func restartFinder(_ sender: Any) {
        let apps: [NSRunningApplication] = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.finder")
        if apps.count != 0 {
            finder = apps[0]
            finder?.addObserver(self, forKeyPath: "isTerminated", context: nil)
//            finder.addObserver(self, forKeyPath: "isTerminated", options: 0, context: "QuitFinder")
            finder?.terminate()
        }
    }

    @IBAction func refreshWindow(_ sender: NSToolbarItem) {
        AppDelegate.shared.setAppDirectory()
        let dir = AppDelegate.shared.appDirectory
        viewController!.resetView()
        viewController!.url = URL(fileURLWithPath: dir)
    }
}
