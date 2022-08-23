//  Converted to Swift 5.6.1 by Swiftify v5.6.26165 - https://swiftify.com/
//
//  AppEntry.swift
//  AppExpose
//
//  Created by Dave Carlton on 4/13/12.
//  Copyright (c) 2012 Polymicro Systems. All rights reserved.
//

import Foundation
import PMUtility
import xattr

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
        let result = isFolder && (childEntries?.count ?? 0) > 0
        return result
    }
    var name: String?
    var appURL: URL?
    var childEntries: [AnyHashable]?
    var iconDictionary: [AnyHashable : Any]?
    var iconImage: NSImage?
    var originalImage: NSImage?
    var isFolder = false
    var attributes: [AnyHashable : Any]?
    var xattr: XATTR?

    class func root() -> AppEntry? {
        return self.init(rootWithURL: URL(fileURLWithPath: "/"))
    }

    init?(rootWithURL url: URL?) {
        super.init()
        appURL = url?.copy()
        isLeaf = true
        isApp = false
        name = url?.lastPathComponent
        originalImage = NSWorkspace.shared.icon(forFile: appURL?.path ?? "")
        iconImage = originalImage
        if let iconImage = iconImage {
            iconDictionary = [
                KEY_IMAGE : iconImage,
                KEY_NAME : name ?? ""
            ]
        }
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
        path?.lineCapStyle = NSSquareLineCapStyle
        NSGraphicsContext.current?.saveGraphicsState()
        path?.addClip()
        path?.stroke()
        NSGraphicsContext.current?.restoreGraphicsState()
    }

    func composeIcons() -> NSImage? {
        let numImages = childEntries?.count ?? 0
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
            var i: Int
            var j: Int
            let count = Int(min(9, numImages))
            var stop = false
            var point: NSPoint
            //        CGFloat offset = resultImageSize.width / 8.0;
            let offset = resultImageSize.width * 0.64065
            point.y = offset
            PMLOG_DEBUG("name: %@ images: %d", name, numImages)

            for i in 0..<3 {
                point.x = offset
                for j in 0..<3 {
                    let entry = childEntries?[(i * 3) + j] as? AppEntry
                    let imageToCompose = entry?.iconImage
                    imageToCompose?.size = littleIconSize
                    PMLOG_DEBUG("point: %f,%f", point.x, point.y)
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
            reducer.setInputImage(resultImage)
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
            let entry = childEntries?[0] as? AppEntry
            if let copy = entry?.iconImage {
                resultImage = copy
            }
        }
        return resultImage
    }

    init?(url: URL?) {
        super.init()
        let fm = FileManager()
        appURL = url?.copy()
        do {
            attributes = try fm.attributesOfItem(atPath: url?.path ?? "")
        } catch {
        }
        if let url = url {
            xattr = XATTR.init(url: url, options: nofollow)
        }
        isLeaf = isALeaf(url)
        isFolder = isAFolder(url)
        hasCustomIcon = hasACustomIcon()
        isApp = isAnApp(url)
        canAccess = userCanAccess()
        name = url?.lastPathComponent
        if isFolder && hasMyCustomIcon {
            originalImage = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(kGenericFolderIcon))
        } else {
            originalImage = NSWorkspace.shared.icon(forFile: appURL?.path ?? "")
        }
        originalImage?.size = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
        iconImage = originalImage
        if isApp {
            isLeaf = false
        } else {
            childEntries = []
            if isFolder && isNotSpecial() {
                scanURL(forIcons: url, for: self)
                if (childEntries?.count ?? 0) != 0 {
                    iconImage = composeIcons()
                }
            }
        }
        if let iconImage = iconImage {
            iconDictionary = [
                KEY_IMAGE : iconImage,
                KEY_NAME : name ?? ""
            ]
        }
    }

    func isNotSpecial() -> Bool {
        let specialNames = ["Utilities"]
        let result = specialNames.contains(name ?? "")
        return !result
    }

    func scanURL(forIcons directoryToScan: URL?, for appEntry: AppEntry?) {
        let fm = FileManager()
        let fileKeys = [.isPackageKey]
        let dirEnumerator = fm.enumerator(
            at: directoryToScan,
            includingPropertiesForKeys: fileKeys,
            options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles,
            errorHandler: nil)
        if let dirEnumerator = dirEnumerator {
            for theURL in dirEnumerator {
                guard let theURL = theURL as? URL else {
                    continue
                }

                // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
                var fileName: String?
                try? (theURL as NSURL).getResourceValue(AutoreleasingUnsafeMutablePointer<AnyObject?>(mutating: &fileName), forKey: .nameKey)

                // Retrieve whether a directory. From NSURLIsDirectoryKey, also
                // cached during the enumeration.
                var isAFolder: NSNumber?
                try? (theURL as NSURL).getResourceValue(&isAFolder, forKey: .isDirectoryKey)

                var isSymLink: NSNumber?
                try? (theURL as NSURL).getResourceValue(&isSymLink, forKey: .isSymbolicLinkKey)

                var isPackage: NSNumber?
                try? (theURL as NSURL).getResourceValue(&isPackage, forKey: .isPackageKey)

                var customIcon: NSImage?
                try? (theURL as NSURL).getResourceValue(&customIcon, forKey: .customIconKey)

                // Ignore files under the app directory
                if isAFolder?.boolValue ?? false {
                    if isPackage?.boolValue ?? false {
                        let entry = AppEntry(url: theURL)
                        if entry?.isApp ?? false {
                            PMLOG(2, "adding: %@", theURL)
                            if appEntry?.addChildEntry(entry) ?? false {
                                dirEnumerator?.skipDescendents()
                            }
                        } else {
                            dirEnumerator?.skipDescendents()
                        }
                    }
                    if (dirEnumerator?.level ?? 0) > MAX_LEVEL {
                        dirEnumerator?.skipDescendents()
                    }
                }
            }
        }
    }

    func isALeaf(_ url: URL?) -> Bool {
        let fileType = attributes?[FileAttributeKey.type] as? String
        if fileType == .typeDirectory {
            return false // folders are not leafs
        }
        if fileType == .typeSymbolicLink {
            return false // symlinks can't be a leaf for now
        }
        if url?.pathExtension == "app" {
            return false // nor are Apps
        }
        return true
    }

    func isAFolder(_ url: URL?) -> Bool {
        let fileType = attributes?[FileAttributeKey.type] as? String
        if fileType == .typeSymbolicLink {
            return false // symlinks can't be a folder for now
        }
        return (fileType == .typeDirectory) ? true : false
    }

    func isAnApp(_ url: URL?) -> Bool {
        let ws = NSWorkspace.shared
        let result = ws.isFilePackage(atPath: url?.path ?? "")
        return result
    }

    func userCanAccess() -> Bool {
        let fm = FileManager.default
        let result1 = fm.isWritableFile(atPath: appURL?.path ?? "")
        var result2 = false
        do {
            result2 = try appURL?.checkResourceIsReachable() ?? false
        } catch {
        }
        if !result1 || !result2 {
            PMLOG(2, "no access: %@", appURL)
        }
        return result1 && result2
    }

    func hasACustomIcon() -> Bool {
        let fm = FileManager.default
        let customIconURL = appURL?.appendingPathComponent(CUSTOM_ICON_NAME)
        let result = fm.fileExists(atPath: customIconURL?.path ?? "")
        return result
    }

    func pathWithName() -> String? {
        let path = URL(fileURLWithPath: appURL?.path ?? "").appendingPathComponent(name ?? "").path
        return isLeaf ? path : path + "/"
    }

    @objc func compare(_ other: AppEntry?) -> ComparisonResult {
        return name?.localizedCaseInsensitiveCompare(other?.name ?? "") ?? ComparisonResult.orderedSame
    }

    func addChildEntry(_ entry: AppEntry?) -> Bool {
        if childEntries == nil {
            return false
        }
        if let entry = entry {
            childEntries?.append(entry)
        }
        childEntries = (childEntries as NSArray?)?.sortedArray(using: Selector("compare:")) as? [AnyHashable] ?? childEntries
        return true
    }

    func childDirectoryEntry(withName str: String?, createIfNotPresent flag: Bool) -> AppEntry? {
        var childEntry: AppEntry? = nil
        for entry in childEntries ?? [] {
            guard let entry = entry as? AppEntry else {
                continue
            }
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

    func setAttribute(_ xAttribute: String!, value xValue: String!) {
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
        let point = NSPoint(0.0, 0.0)
        let currentSize = iconImage?.size
        let currentRect = NSRect(point, currentSize)

        // setup the badge image and size
        let mb = Bundle.main
        let badgeImageURL = mb.url(forResource: "red-lock", withExtension: "png")
        var badgeImage: NSImage? = nil
        if let badgeImageURL = badgeImageURL {
            badgeImage = NSImage(contentsOf: badgeImageURL)
        }
        let badgePoint = NSPoint(0.0, 0.0)
        let badgeSize = NSMakeSize((iconImage?.size.width ?? 0.0) / 4.0, (iconImage?.size.height ?? 0.0) / 4.0)
        //	[badgeImage setSize: badgeSize];

        // draw current image badged
        let currentImageBadged = NSImage(size: currentSize ?? NSSize.zero)
        currentImageBadged.lockFocus()
        iconImage?.draw(at: badgePoint, from: currentRect, operation: .sourceOver, fraction: 1.0)
        badgeImage?.draw(
            in: NSRect(x: 0, y: 0, width: badgeSize.width, height: badgeSize.height),
            from: NSRect.zero /* Draws full image. */,
            operation: .sourceOver,
            fraction: 0.7)
        currentImageBadged.unlockFocus()
        iconImage = currentImageBadged

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
        iconDictionary?[KEY_IMAGE] = iconImage
    }

    func badgeAsFolder() {
        // Setup for the composite image with size same as the current icon
        let point = NSPoint(0.0, 0.0)
        let currentSize = iconImage?.size
        let currentRect = NSRect(point, currentSize)

        // setup the badge image and size
        let mb = Bundle.main
        let badgeImageURL = mb.url(forResource: "Folder", withExtension: "png")
        var badgeImage: NSImage? = nil
        if let badgeImageURL = badgeImageURL {
            badgeImage = NSImage(contentsOf: badgeImageURL)
        }
        let badgePoint = NSPoint(0.0, 0.0)
        let badgeSize = NSMakeSize((iconImage?.size.width ?? 0.0) / 4.0, (iconImage?.size.height ?? 0.0) / 4.0)
        //	[badgeImage setSize: badgeSize];

        // draw current image badged
        let currentImageBadged = NSImage(size: currentSize ?? NSSize.zero)
        currentImageBadged.lockFocus()
        iconImage?.draw(at: badgePoint, from: currentRect, operation: .sourceOver, fraction: 1.0)
        badgeImage?.draw(
            in: NSRect(x: 0, y: 0, width: badgeSize.width, height: badgeSize.height),
            from: NSRect.zero /* Draws full image. */,
            operation: .sourceOver,
            fraction: 0.7)
        currentImageBadged.unlockFocus()
        iconImage = currentImageBadged

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
        iconDictionary?[KEY_IMAGE] = iconImage
    }
}

extension NSImage {
    func dump() {
        let imgRep = representations[0] as? NSBitmapImageRep
        let data = imgRep?.representation(using: .png, properties: [:])
        //    [imgRep representationUsingType:NSBitmapImageFileTypePNG properties:nil];
        if let data = data {
            NSData(data: data).write(toFile: "/tmp/image.png", atomically: false)
        }
    }
}