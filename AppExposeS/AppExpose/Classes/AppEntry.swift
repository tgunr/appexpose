//
//  AppEntry.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/4/22.
//

import AppKit
import Cocoa
import Foundation
import UniformTypeIdentifiers
// import PMUtility
// import xattr

let KEY_IMAGE = "icon"
let KEY_NAME = "name"
let ICON_SIZE = 1024.0
let DEFAULT_ICON_SIZE = 128.0
let CUSTOM_ICON_NAME = "Icon\r"
let CUSTOM_ICON_ID = "com.polymicrosystems.appexpose.customicon"
let MAX_LEVEL = 2

class AppFolder: ObservableObject {
    @Published var model: AppEntry?
}

class AppEntry: NSObject, Identifiable, ObservableObject {
    var childIcons: [AnyHashable]?
    var isLeaf = false
    var isApp = false
    var canAccess = false
    var hasCustomIcon = false
    var originalFolderIcon: NSImage?
    var hasMyCustomIcon: Bool {
        return xattr?.hasAttribute(CUSTOM_ICON_ID) ?? false
    }

    var skipDescendents: Bool {
        let result = isFolder && (children.count > 0)
        return result
    }

    var name: String?
    var appURL: URL?
    @Published var children = [AppEntry]()
    var iconDictionary: [String: NSImage]?
    var icons: [NSImage]?
    var appImage: NSImage?
    var originalImage: NSImage?
    var isFolder = false
    var attributes: [FileAttributeKey: Any] = [:]
    var xattr: XATTR?
    var processedURLs = Set<URL>()

    class func root() -> AppEntry? {
        let root = self.init(withURL: URL(fileURLWithPath: "/"))
        return root
    }

    init(name: String) {
        self.name = name
    }

    required init(withURL url: URL) {
        super.init()
        appURL = url
        symlog.value("\(#function) url: \(url.path)")
        do {
            attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            xattr = XATTR(path: url.path, options: XATTROptions.nofollow)
            isLeaf = isALeaf(appURL)
            isFolder = isAFolder(appURL)
            hasCustomIcon = hasACustomIcon()
            isApp = isAnApp(appURL)
            canAccess = userCanAccess()
            if isFolder && hasMyCustomIcon {
                originalImage = NSWorkspace.shared.icon(for: UTType.folder)
            } else {
                originalImage = NSWorkspace.shared.icon(forFile: appURL?.path ?? "")
            }
            originalImage?.size = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
            appImage = originalImage
        } catch {
            symlog.error("attributes: FAIL")
        }
        name = appURL?.lastPathComponent
        // Check if the item is a folder or application
        icons = []
    }

    init(url: URL?) {
        symlog.debug("\(#function) url: \(url?.path ?? "null")")
        super.init()
        let fm = FileManager()
        appURL = url
        do {
            attributes = try fm.attributesOfItem(atPath: url?.path ?? "")
        } catch {
            symlog.error("attributes: FAIL")
        }
        if let url = url {
            xattr = XATTR(path: url.path(), options: XATTROptions.nofollow)
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
            children = []
            if isFolder && isNotSpecial() {
                scanURL()
                if (children.count) != 0 {
                    appImage = composeIcons()
                }
            }
        }
        if let iconImage = appImage {
            iconDictionary = [
                KEY_IMAGE: iconImage]
        }
    }

    func scanApplications(atPath: String?, currentDirectory: String?) -> [AppEntry] {
        var entries: [AppEntry] = []

        guard let currentDir = atPath ?? currentDirectory else { return entries }
        let fm = FileManager.default

        do {
//            let contents = try fm.contentsOfDirectory(atPath: currentDir)
            let keys = [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey, URLResourceKey.isPackageKey]
            let contents = try fm.contentsOfDirectory(at: URL(fileURLWithPath: currentDir), includingPropertiesForKeys: keys, options: .skipsHiddenFiles)

            for item in contents {
                if item.path.hasSuffix("Applications") || item.path.hasSuffix(".Trash") { continue }

                let fullPath = item.path
                let directoryEntry = AppEntry(withURL: item)
                // Check if the item is a folder or application

                if directoryEntry.isApp {
                    directoryEntry.isLeaf = false
//                    directoryEntry.appImage = NSImage(size: NSSize(width: 50, height: 50))
//                    directoryEntry.appImage?.lockFocus()
//                    let iconURL = URL(fileURLWithPath: fullPath)
//                        .appendingPathComponent("Contents")
//                        .appendingPathComponent("Resources")
//                        .appendingPathComponent("\(item).icns")
//                    if let image = NSImage(contentsOf: iconURL) {
//                        directoryEntry.appImage = image
//                    } else {
//                        symlog.error("Failed to load icon for \(item)")
//                    }
//                    directoryEntry.appImage?.unlockFocus()
                    entries.append(directoryEntry)
                    symlog.value("Added \(item) to entries")
                    continue
                }

                if directoryEntry.isFolder && directoryEntry.isNotSpecial() {
                    let subDirEntries = scanApplications(atPath: nil, currentDirectory: fullPath)
                    entries.append(contentsOf: subDirEntries)
                    symlog.value("Added \(subDirEntries.count) entries")
                }
            }
        } catch {
            symlog.error("Error scanning directory: \(error)")
        }
        return entries
    }

    func scanApplications1(atPath path: String, currentDirectory: AppEntry? = nil) -> [AppEntry] {
        // Get the contents of the directory at the specified path
        let fm = FileManager()
        do {
            let contents = try fm.contentsOfDirectory(atPath: path)

            // Create an entry for the current directory
            var directoryEntry: AppEntry?
            if currentDirectory != nil {
                directoryEntry = currentDirectory!
            } else {
                directoryEntry = AppEntry(withURL: URL(fileURLWithPath: path))
            }
            directoryEntry?.appURL = URL(fileURLWithPath: path)
            directoryEntry?.attributes = try FileManager.default.attributesOfItem(atPath: path)
            directoryEntry?.xattr = XATTR(path: path, options: XATTROptions.nofollow)
            directoryEntry?.isLeaf = ((directoryEntry?.isALeaf(appURL)) != nil)
            directoryEntry?.isFolder = isAFolder(appURL)
            directoryEntry?.hasCustomIcon = ((directoryEntry?.hasACustomIcon()) != nil)
            directoryEntry?.isApp = isAnApp(appURL)
            directoryEntry?.canAccess = ((directoryEntry?.userCanAccess()) != nil)
            directoryEntry?.name = appURL?.lastPathComponent
            // Check if the item is a folder or application
            if directoryEntry!.isFolder && ((directoryEntry?.hasMyCustomIcon) != nil) {
                directoryEntry?.originalImage = NSWorkspace.shared.icon(for: UTType.folder)
            } else {
                directoryEntry?.originalImage = NSWorkspace.shared.icon(forFile: appURL?.path ?? "")
            }
            directoryEntry?.originalImage?.size = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
            directoryEntry?.appImage = directoryEntry?.originalImage

            // Iterate through the contents of the directory
            for item in contents {
                let fullPath = "\(path)/\(item)"
                let appEntry = AppEntry(withURL: URL(fileURLWithPath: fullPath))
                if appEntry.isApp {
                    appEntry.isLeaf = false
                    directoryEntry?.children.append(appEntry)
                } else {
                    if appEntry.isFolder && appEntry.isNotSpecial() {
                        let children = scanApplications1(atPath: fullPath, currentDirectory: directoryEntry)
                        appEntry.children.append(contentsOf: children.map { $0 })
                        directoryEntry?.children.append(appEntry)
                    }
                }
            }

            return [directoryEntry!]
        } catch {
            print("Error scanning directory at path \(path): \(error)")
            return []
        }
    }

    func draw(_ image: NSImage?, withFrame imageFrame: NSRect) {
        // [super drawImage:image withFrame:imageFrame inView:controlView];

        NSGraphicsContext.saveGraphicsState()

        let path = NSBezierPath(roundedRect: imageFrame, xRadius: 5, yRadius: 5)
        path.addClip()

        // set the size
        image?.size = imageFrame.size

        // draw the image
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
        let numImages = children.count
        let resultImageSize = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
        var resultImage = NSImage(size: resultImageSize)

        if numImages > 1 {
            let mb = Bundle.main
            let bgImageURL = mb.url(forResource: "default", withExtension: "png")
            var bgImage: NSImage?
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
            var point: NSPoint = NSPoint(x: 0.0, y: 0.0)
            //        CGFloat offset = resultImageSize.width / 8.0;
            let offset = resultImageSize.width * 0.64065
            point.y = offset
            //            PMLOG_DEBUG("name: %@ images: %d", name, numImages)

            for i in 0 ..< 3 {
                point.x = offset
                for j in 0 ..< 3 {
                    let entry = children[(i * 3) + j]
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
            reducer?.setMaxPixelsWide(512)
            reducer?.setMaxPixelsHigh(512)
            reducer?.setScalesImage(true)
            reducer?.setSharpensImage(false)
            reducer?.setDrawBorder(true)
            reducer?.setAddsShadow(true)
            var reduced = reducer?.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }

            reducer?.setMaxPixelsWide(256)
            reducer?.setMaxPixelsHigh(256)
            reduced = reducer?.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }

            reducer?.setMaxPixelsWide(128)
            reducer?.setMaxPixelsHigh(128)
            reduced = reducer?.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }

            reducer?.setMaxPixelsWide(64)
            reducer?.setMaxPixelsHigh(64)
            reduced = reducer?.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }

            reducer?.setMaxPixelsWide(32)
            reducer?.setMaxPixelsHigh(32)
            reduced = reducer?.outputBitmapImageRep()
            if let reduced = reduced {
                resultImage.addRepresentation(reduced)
            }
        } else {
            let entry = children[0]
            if let copy = entry.appImage {
                resultImage = copy
            }
        }
        return resultImage
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
            symlog.error("checkResourceIsReachable: FAIL")
        }
        return result2
        if !result1 || !result2 {
            symlog.error("no access: \(String(describing: appURL?.absoluteString))")
        }
        return result1 && result2
    }

    func hasACustomIcon() -> Bool {
        let fm = FileManager.default
        let customIconURL = appURL?.appendingPathComponent(CUSTOM_ICON_NAME)
        let result = fm.fileExists(atPath: customIconURL!.path)
        return result
    }

    /// Looks in the directoryToScan items which are directories or packages. If found an entry is created and checked if it is an application.
    /// If so, the entry is added as a child entry. If the item was a package, no further recursion is needed as packages are not applications per say.
    /// The folder being scanned is limited by the value in MAX_LEVEL
    func scanURL() {
        let fm = FileManager.default
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey, .isPackageKey, .customIconKey])
        let directoryEnumerator = fm.enumerator(at: appURL!, includingPropertiesForKeys: Array(resourceKeys), options: [.skipsHiddenFiles, .skipsPackageDescendants])!

        var newEntries: [AppEntry] = []

        while let fileURL = directoryEnumerator.nextObject() as? URL {
            // Retrieve the directory property
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                  let isDirectory = resourceValues.isDirectory,
                  let isPackage = resourceValues.isPackage
            else {
                continue
            }

            if isDirectory {
                let entry = AppEntry(url: fileURL)
                if !newEntries.contains(where: { $0.appURL == entry.appURL }) {
                    newEntries.append(entry)
                    if isPackage {
                        if entry.isApp {
                            directoryEnumerator.skipDescendents()
                        }
                    }
                    if (directoryEnumerator.level) > MAX_LEVEL {
                        directoryEnumerator.skipDescendents()
                    }
                }
            }
        }

        // Update the entries property with the new entries
        DispatchQueue.main.async {
            self.children = newEntries
            self.objectWillChange.send()
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
            children.append(entry)
            return true
        } else {
            return false
        }
    }

    func childDirectoryEntry(withName str: String?, createIfNotPresent flag: Bool) -> AppEntry? {
        var childEntry: AppEntry?
        for entry in children {
            if (entry.name == str) && !entry.isLeaf {
                childEntry = entry
                break
            }
        }
        if childEntry == nil && flag && !isLeaf {
            childEntry = AppEntry(
                url: URL(
                    string: URL(fileURLWithPath: pathWithName() ?? "").appendingPathComponent(str ?? "").path + "/"))
            _ = addChildEntry(childEntry)
        }
        return childEntry
    }

    func add(toRootEntry rootEntry: AppEntry) -> Bool {
        var directoryEntry = rootEntry
        let components = appURL?.pathComponents
        for component in components ?? [] {
            if "/" != component {
                directoryEntry = directoryEntry.childDirectoryEntry(withName: component, createIfNotPresent: true)!
            }
        }
        return Bool(directoryEntry != nil ? directoryEntry.addChildEntry(self) : false)
    }

    func setAttribute(_ xAttribute: String!, value xValue: String!) -> Bool {
        xattr?.setAttribute(xAttribute, value: xValue)
        return true
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
        var badgeImage: NSImage?
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

    func badge() {
        // Setup for the composite image with size same as the current icon
        let point = NSPoint(x: 0.0, y: 0.0)
        let currentSize = appImage?.size
        let currentRect = NSRect(origin: point, size: currentSize!)

        // setup the badge image and size
        let mb = Bundle.main
        let badgeImageURL = mb.url(forResource: "Badge", withExtension: "png")
        var badgeImage: NSImage?
        if let badgeImageURL = badgeImageURL {
            badgeImage = NSImage(contentsOf: badgeImageURL)
        }
        let badgePoint = NSPoint(x: 0.0, y: 0.0)
        let badgeSize = NSMakeSize((appImage?.size.width ?? 0.0) / 4.0, (appImage?.size.height ?? 0.0) / 4.0)

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
        if !isFolder {
            return
        }

        // ask_software_developer How to get the icon used for a folder?
        var folderIcon = NSWorkspace.shared.icon(for: UTType.folder)
        // Setup for the composite image with size same as the current icon
        let point = NSPoint(x: 0.0, y: 0.0)
        let currentSize = folderIcon.size
        let currentRect = NSRect(origin: point, size: currentSize)

        // setup the badge image and size
        let mb = Bundle.main
        let badgeImageURL = mb.url(forResource: "Folder", withExtension: "png")
        var badgeImage: NSImage?
        if let badgeImageURL = badgeImageURL {
            badgeImage = NSImage(contentsOf: badgeImageURL)
        }
        let badgePoint = NSPoint(x: 0.0, y: 0.0)
        let badgeSize = NSMakeSize(folderIcon.size.width / 4.0, folderIcon.size.height / 4.0)

        // draw current image badged
        let currentImageBadged = NSImage(size: currentSize)
        currentImageBadged.lockFocus()
        folderIcon.draw(at: badgePoint, from: currentRect, operation: .sourceOver, fraction: 1.0)
        badgeImage?.draw(
            in: NSRect(x: 0, y: 0, width: badgeSize.width, height: badgeSize.height),
            from: NSRect.zero /* Draws full image. */,
            operation: .sourceOver,
            fraction: 0.7)
        currentImageBadged.unlockFocus()
        folderIcon = currentImageBadged

        // draw original image badged
        let originalImageBadged = NSImage(size: currentSize)
        originalImageBadged.lockFocus()
        originalFolderIcon?.draw(at: badgePoint, from: currentRect, operation: .sourceOver, fraction: 1.0)
        badgeImage?.draw(
            in: NSRect(x: 0, y: 0, width: badgeSize.width, height: badgeSize.height),
            from: NSRect.zero /* Draws full image. */,
            operation: .sourceOver,
            fraction: 0.7)
        originalImageBadged.unlockFocus()
        originalFolderIcon = originalImageBadged

        // set dictionary with badge version
        //        iconDictionary?[KEY_IMAGE] = folderIcon
    }

    func badgeAsFolderOLD() {
        // Setup for the composite image with size same as the current icon
        let point = NSPoint(x: 0.0, y: 0.0)
        let currentSize = appImage?.size
        let currentRect = NSRect(origin: point, size: currentSize!)

        // setup the badge image and size
        let mb = Bundle.main
        let badgeImageURL = mb.url(forResource: "Folder", withExtension: "png")
        var badgeImage: NSImage?
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

extension NSImage {
    func dump() {
        let imageRep: NSBitmapImageRep? = representations[0] as? NSBitmapImageRep
        let imageData = imageRep?.representation(
            using: NSBitmapImageRep.FileType.png,
            properties: [:])
        let url = URL(string: "/tmp/image.png")
        try! imageData!.write(to: url!, options: [])
    }
}
