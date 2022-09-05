//
//  AppEntry.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/4/22.
//

import Cocoa
import Foundation
import AppKit
import UniformTypeIdentifiers
//import PMUtility
//import xattr

let KEY_IMAGE = "icon"
let KEY_NAME = "name"
let ICON_SIZE = 1024.0
let DEFAULT_ICON_SIZE = 128.0
let CUSTOM_ICON_NAME = "Icon\r"
let CUSTOM_ICON_ID = "com.polymicrosystems.appexpose.customicon"
let MAX_LEVEL = 2

class AppEntry: NSObject {
    var childIcons: [AnyHashable]?
    var isLeaf = false
    var isApp = false
    var canAccess = false
    var hasCustomIcon = false
    var hasMyCustomIcon: Bool {
        return xattr?.hasAttribute(CUSTOM_ICON_ID) ?? false
    }
    var skipDescendents: Bool {
        let result = isFolder && (childEntries.count > 0)
        return result
    }
    var name: String?
    var appURL: URL?
    var childEntries: [AppEntry] = [ ]
    //    var iconDictionary: [String : NSImage]?
    var icons: [NSImage]?
    var appImage: NSImage?
    var originalImage: NSImage?
    var isFolder = false
    var attributes: [FileAttributeKey : Any] = [ : ]
    var xattr: XATTR?
    
    class func root() -> AppEntry? {
        let root = self.init(rootWithURL: URL(fileURLWithPath: "/"))
        return root
    }
    
    required init(rootWithURL url: URL?) {
        super.init()
        appURL = url
        isLeaf = true
        isApp = false
        name = appURL?.lastPathComponent
        originalImage = NSWorkspace.shared.icon(forFile: appURL?.path ?? "")
        appImage = originalImage
        icons = []
    }

    func draw(_ image: NSImage?, withFrame imageFrame: NSRect) {
        // [super drawImage:image withFrame:imageFrame inView:controlView];
        
        NSGraphicsContext.saveGraphicsState()
        
        let path = NSBezierPath(roundedRect: imageFrame, xRadius: 5, yRadius: 5)
        path.addClip()
        
        //set the size
        image?.size = imageFrame.size
        
        //draw the image
        image?.draw(in: imageFrame, from: .zero, operation: .sourceOver, fraction: 1.0, respectFlipped: true, hints: nil)
        NSGraphicsContext.restoreGraphicsState()
    }
    
    func draw(_ dirtyRect: NSRect) {
        var path: NSBezierPath?
        var color: NSColor?
        var stroke: CGFloat
        
        // Box
        
        stroke = dirtyRect.size.width / 10.0
        path = NSBezierPath(roundedRect: dirtyRect, xRadius: stroke, yRadius: stroke)
        color = NSColor(calibratedRed: CGFloat(0.8), green: CGFloat(0.8), blue: CGFloat(0.8), alpha: CGFloat(1.0))
        color?.setStroke()
        path?.lineWidth = stroke
        path?.lineCapStyle = NSBezierPath.LineCapStyle.square
        NSGraphicsContext.current?.saveGraphicsState()
        path?.addClip()
        path?.stroke()
        NSGraphicsContext.current?.restoreGraphicsState()
    }
    
    func composeIcons() -> NSImage? {
        let numImages = childEntries.count
        let resultImageSize = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
        var resultImage = NSImage(size: resultImageSize)
        
        if numImages > 1 {
            let mb = Bundle.main
            let bgImageURL = mb.url(forResource: "default", withExtension: "png")
            var bgImage: NSImage? = nil
            if let bgImageURL = bgImageURL {
                bgImage = NSImage(contentsOf: bgImageURL)
            }
            
            let littleIconSize = NSMakeSize(resultImageSize.width / 4.0, resultImageSize.height / 4.0)
            resultImage.lockFocus()
            bgImage?.size = NSMakeSize(resultImageSize.width - 64, resultImageSize.height - 64)
            bgImage?.draw(at: NSPoint(x: 32.0, y: 32.0), from: .zero, operation: .sourceOver, fraction: 0.8)
            draw(NSRect(x: 0.0, y: 0.0, width: CGFloat(ICON_SIZE), height: CGFloat(ICON_SIZE)))
            var count = Int(min(9, numImages))
            var stop = false
            var point: NSPoint
            //        CGFloat offset = resultImageSize.width / 8.0;
            let offset = resultImageSize.width * 0.64065
            point.y = offset
            //            PMLOG_DEBUG("name: %@ images: %d", name, numImages)
            
            for i in 0..<3 {
                point.x = offset
                for j in 0..<3 {
                    let entry = childEntries[(i * 3) + j]
                    let imageToCompose = entry.appImage
                    imageToCompose?.size = littleIconSize
                    //                    PMLOG_DEBUG("point: %f,%f", point.x, point.y)
                    imageToCompose?.draw(at: point, from: .zero, operation: .sourceOver, fraction: 1.0)
                    count -= 1
                    if count == 0 {
                        stop = true
                        break
                    }
                    point.x = (point.x - 256) - 32
                }
                if stop {
                    break
                }
                point.y = (point.y - 256) - 32
            }
            resultImage.unlockFocus()
            let reducer = ImageReducer()
            reducer?.setInputImage(resultImage)
            reducer.maxPixelsWide = 512
            reducer.maxPixelsHigh = 512
            reducer.scalesImage = true
            reducer.sharpensImage = false
            reducer.drawBorder = false
            reducer.addsShadow = false
            var reduced = reducer.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }
            
            reducer.maxPixelsWide = 256
            reducer.maxPixelsHigh = 256
            reduced = reducer.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }
            
            reducer.maxPixelsWide = 128
            reducer.maxPixelsHigh = 128
            reduced = reducer.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }
            
            reducer.maxPixelsWide = 64
            reducer.maxPixelsHigh = 64
            reduced = reducer.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }
            
            reducer.maxPixelsWide = 32
            reducer.maxPixelsHigh = 32
            reduced = reducer.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }
        } else {
            let entry = childEntries[0]
            if let copy = entry.appImage {
                resultImage = copy
            }
        }
        return resultImage
    }
    
    init(url: URL?) {
        super.init()
        let fm = FileManager()
        appURL = url
        do {
            attributes = try fm.attributesOfItem(atPath: url?.path ?? "")
        } catch {
        }
        if let url = url {
            xattr = XATTR(path: url.path(), options: nofollow)
        }
        isLeaf = isALeaf(url)
        isFolder = isAFolder(url)
        hasCustomIcon = hasACustomIcon()
        isApp = isAnApp(url)
        canAccess = userCanAccess()
        name = url?.lastPathComponent
        if isFolder && hasMyCustomIcon {
            originalImage = NSWorkspace.shared.icon(for: UTType.folder)
        } else {
            originalImage = NSWorkspace.shared.icon(forFile: appURL?.path ?? "")
        }
        originalImage?.size = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
        appImage = originalImage
        if isApp {
            isLeaf = false
        } else {
            childEntries = []
            if isFolder && isNotSpecial() {
                scanURL(forIcons: url, for: self)
                if (childEntries.count) != 0 {
                    appImage = composeIcons()
                }
            }
        }
        if let iconImage = appImage {
            iconDictionary = [
                KEY_IMAGE : iconImage,
                KEY_NAME : name ?? ""
            ]
        }
    }
    
    func isALeaf(_ url: URL?) -> Bool {
        let fileType = attributes[FileAttributeKey.type] as! String
        
        if fileType == "NSFileTypeDirectory" {
            return false // folders are not leafs
        }
        if fileType == "NSFileTypeSymbolicLink" {
            return false // symlinks can't be a leaf for now
        }
        if url?.pathExtension == "app" {
            return false // nor are Apps
        }
        return true
    }
    
    func isAFolder(_ url: URL?) -> Bool {
        let fileType = attributes[FileAttributeKey.type] as? String
        if fileType == "NSFileTypeSymbolicLink" {
            return false // symlinks can't be a folder for now
        }
        return (fileType == "NSFileTypeDirectory") ? true : false
    }
    
    func isAnApp(_ url: URL?) -> Bool {
        let ws = NSWorkspace.shared
        let result = ws.isFilePackage(atPath: url?.path ?? "")
        return result
    }
    
    func isNotSpecial() -> Bool {
        let specialNames = ["Utilities"]
        let result = specialNames.contains(name ?? "")
        return !result
    }
    
    func userCanAccess() -> Bool {
        let fm = FileManager.default
        let result1 = fm.isWritableFile(atPath: (appURL?.path())!)
        var result2 = false
        do {
            result2 = ((try appURL?.checkResourceIsReachable()) != nil)
        } catch {
        }
        if !result1 || !result2 {
            //            PMLOG(2, "no access: %@", appURL)
        }
        return result1 && result2
    }
    
    func hasACustomIcon() -> Bool {
        let fm = FileManager.default
        let customIconURL = appURL?.appendingPathComponent(CUSTOM_ICON_NAME)
        let result = fm.fileExists(atPath: customIconURL!.path)
        return result
    }
    
    func scanURL(forIcons directoryToScan: URL?, for appEntry: AppEntry?) {
        let fm = FileManager.default
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey, .isPackageKey, .customIconKey])
        let directoryEnumerator = fm.enumerator(at: directoryToScan!, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)!
        
        for case let fileURL as URL in directoryEnumerator {
            // Retrieve the directory property
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  //                      let isSymLink = resourceValues.isSymbolicLink,
                  let isPackage = resourceValues.isPackage
                    //                      let isCustom = resourceValues.customIcon,
                    //                      let fileName = resourceValues.name
            else {
                continue
            }
            if isDirectory {
                if isPackage {
                    let entry = AppEntry(url: fileURL)
                    if entry.isApp {
                        //                        PMLOG(2, "adding: %@", fileURL)
                        if entry.addChildEntry(entry) {
                            directoryEnumerator.skipDescendents()
                        }
                    } else {
                        directoryEnumerator.skipDescendents()
                    }
                }
                if (directoryEnumerator.level ) > MAX_LEVEL {
                    directoryEnumerator.skipDescendents()
                }
            }
        }
    }
    
    class func collectFolders(_ directoryToScan: URL?) -> AppEntry {
        let appEntry = AppEntry(url: directoryToScan)
        let fm = FileManager()
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey, .isPackageKey, .customIconKey])
        let dirEnumerator = fm.enumerator(at: directoryToScan!, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)!
        let tempArray: [AnyHashable] = []
        
        for case let fileURL as URL in dirEnumerator {
            // Retrieve the directory property
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  //                      let isSymLink = resourceValues.isSymbolicLink,
                  let isPackage = resourceValues.isPackage
                    //                      let isCustom = resourceValues.customIcon,
                    //                      let fileName = resourceValues.name
            else {
                continue
            }
            
            if isDirectory {
                if isPackage {
                    let entry = AppEntry(url: fileURL)
                    if entry.isApp {
                        //                        PMLOG(2, "adding: %@", fileURL)
                        if appEntry.addChildEntry(entry) {
                            dirEnumerator.skipDescendents()
                        }
                    } else {
                        dirEnumerator.skipDescendents()
                    }
                }
                if (dirEnumerator.level ) > MAX_LEVEL {
                    dirEnumerator.skipDescendents()
                }
            }
            return appEntry
            //        [[[[AppDelegate shared] myWindowController] progressIndicator] stopAnimation:self];
            //        [[[[AppDelegate shared] myWindowController] progressIndicator] setHidden:YES];
            performSelector(onMainThread: Selector(("setIcons:")), with: tempArray, waitUntilDone: true)
            //        [collectionView setSelectionIndexes:[NSIndexSet indexSet]];
        }
    }
    
    func folderHasCustomIcon(path: String) -> Bool {
        let iconPath = NSString.path(withComponents: [path, "Icon\r"])
        let r = FileManager.default.fileExists(atPath: iconPath)
        return r
    }
    
    func pathWithName() -> String? {
        let path = URL(fileURLWithPath: appURL?.path ?? "").appendingPathComponent(name ?? "").path
        return isLeaf ? path : path + "/"
    }
    
    func compare(_ other: AppEntry?) -> ComparisonResult {
        return name?.localizedCaseInsensitiveCompare(other?.name ?? "") ?? ComparisonResult.orderedSame
    }
    
    func addChildEntry(_ entry: AppEntry?) -> Bool {
        if let entry = entry {
            self.childEntries.append(entry)
            return true
        } else {
            return false
        }
    }
    
    func childDirectoryEntry(withName str: String?, createIfNotPresent flag: Bool) -> AppEntry? {
        var childEntry: AppEntry? = nil
        for entry in childEntries {
            if (entry.name == str) && !entry.isLeaf {
                childEntry = entry
                break
            }
        }
        if childEntry == nil && flag && !isLeaf {
            childEntry = AppEntry(
                url: URL(
                    string: URL(fileURLWithPath: pathWithName() ?? "").appendingPathComponent(str ?? "").path + "/"))
            addChildEntry(childEntry)
        }
        return childEntry
    }
    
    func add(toRootEntry rootEntry: AppEntry?) -> Bool {
        var directoryEntry = rootEntry
        let components = appURL?.pathComponents
        for component in components ?? [] {
            if "/" != component {
                directoryEntry = directoryEntry?.childDirectoryEntry(withName: component, createIfNotPresent: true)
            }
        }
        return Bool((directoryEntry != nil ? directoryEntry?.addChildEntry(self) : false) ?? false)
    }
    
    func setAttribute(_ xAttribute: String!, value xValue: String!) -> Bool {
        let ok = xattr?.setAttribute(xAttribute, value: xValue) ?? false
        return ok
    }
    
    func hasAttribute(_ string: String?) -> Bool {
        let result = xattr?.hasAttribute(string) ?? false
        return result
    }
    
    func deleteAttribute(_ string: String?) -> Bool {
        var ok = false
        if hasAttribute(string) {
            ok = xattr?.deleteAttribute(string) ?? false
        }
        return ok
    }
    
    func revertIcon() {
        //    iconImage = originalImage;
    }
    
    func badgeAsNoAccess() {
        // Setup for the composite image with size same as the current icon
        let point = NSPoint(x: 0.0, y: 0.0)
        let currentSize = appImage?.size
        let currentRect = NSRect(origin: point, size: currentSize!)
        
        // setup the badge image and size
        let mb = Bundle.main
        let badgeImageURL = mb.url(forResource: "red-lock", withExtension: "png")
        var badgeImage: NSImage? = nil
        if let badgeImageURL = badgeImageURL {
            badgeImage = NSImage(contentsOf: badgeImageURL)
        }
        let badgePoint = NSPoint(x: 0.0, y: 0.0)
        let badgeSize = NSMakeSize((appImage?.size.width ?? 0.0) / 4.0, (appImage?.size.height ?? 0.0) / 4.0)
        //    [badgeImage setSize: badgeSize];
        
        // draw current image badged
        let currentImageBadged = NSImage(size: currentSize ?? NSSize.zero)
        currentImageBadged.lockFocus()
        appImage?.draw(at: badgePoint, from: currentRect, operation: .sourceOver, fraction: 1.0)
        badgeImage?.draw(
            in: NSRect(x: 0, y: 0, width: badgeSize.width, height: badgeSize.height),
            from: NSRect.zero /* Draws full image. */,
            operation: .sourceOver,
            fraction: 0.7)
        currentImageBadged.unlockFocus()
        appImage = currentImageBadged
        
        // draw original image badged
        let originalImageBadged = NSImage(size: currentSize ?? NSSize.zero)
        originalImageBadged.lockFocus()
        originalImage?.draw(at: badgePoint, from: currentRect, operation: .sourceOver, fraction: 1.0)
        badgeImage?.draw(
            in: NSRect(x: 0, y: 0, width: badgeSize.width, height: badgeSize.height),
            from: NSRect.zero /* Draws full image. */,
            operation: .sourceOver,
            fraction: 0.7)
        originalImageBadged.unlockFocus()
        originalImage = originalImageBadged
        
        // set dictionary with badge version
//        iconDictionary?[KEY_IMAGE] = appImage
    }
    
    func badgeAsFolder() {
        // Setup for the composite image with size same as the current icon
        let point = NSPoint(x: 0.0, y: 0.0)
        let currentSize = appImage?.size
        let currentRect = NSRect(origin: point, size: currentSize!)
        
        // setup the badge image and size
        let mb = Bundle.main
        let badgeImageURL = mb.url(forResource: "Folder", withExtension: "png")
        var badgeImage: NSImage? = nil
        if let badgeImageURL = badgeImageURL {
            badgeImage = NSImage(contentsOf: badgeImageURL)
        }
        let badgePoint = NSPoint(x: 0.0, y: 0.0)
        let badgeSize = NSMakeSize((appImage?.size.width ?? 0.0) / 4.0, (appImage?.size.height ?? 0.0) / 4.0)
        //    [badgeImage setSize: badgeSize];
        
        // draw current image badged
        let currentImageBadged = NSImage(size: currentSize ?? NSSize.zero)
        currentImageBadged.lockFocus()
        appImage?.draw(at: badgePoint, from: currentRect, operation: .sourceOver, fraction: 1.0)
        badgeImage?.draw(
            in: NSRect(x: 0, y: 0, width: badgeSize.width, height: badgeSize.height),
            from: NSRect.zero /* Draws full image. */,
            operation: .sourceOver,
            fraction: 0.7)
        currentImageBadged.unlockFocus()
        appImage = currentImageBadged
        
        // draw original image badged
        let originalImageBadged = NSImage(size: currentSize ?? NSSize.zero)
        originalImageBadged.lockFocus()
        originalImage?.draw(at: badgePoint, from: currentRect, operation: .sourceOver, fraction: 1.0)
        badgeImage?.draw(
            in: NSRect(x: 0, y: 0, width: badgeSize.width, height: badgeSize.height),
            from: NSRect.zero /* Draws full image. */,
            operation: .sourceOver,
            fraction: 0.7)
        originalImageBadged.unlockFocus()
        originalImage = originalImageBadged
        
        // set dictionary with badge version
//        iconDictionary?[KEY_IMAGE] = appImage
    }
}
