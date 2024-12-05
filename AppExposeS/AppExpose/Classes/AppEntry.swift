//
//  AppEntry.swift
//  AppExposeS
//
//  Created by Dave Carlton on 9/4/22.
//

import AppKit
import Cocoa
import CoreServices
import Foundation
import UniformTypeIdentifiers

let KEY_IMAGE = "icon"
let KEY_NAME = "name"
let ICON_SIZE = 1024.0
let DEFAULT_ICON_SIZE = 128.0
let CUSTOM_ICON_NAME = "Icon\r"
let CUSTOM_ICON_ID_OLD = "com.polymicrosystems.appexpose.customicon"
let CUSTOM_ATTRIBUTES = "net.polymicro.appexpose"
let CUSTOM_ICON_ID = CUSTOM_ATTRIBUTES + ".customicon"
let MAX_LEVEL = 2

class AppFolder: ObservableObject {
    @Published var model: AppEntry?
}

@MainActor let workspace = NSWorkspace.shared
@MainActor let filemanager = FileManager.default

@MainActor
class AppEntry: NSObject, @preconcurrency Identifiable, ObservableObject {
    var id: UUID = UUID()
    @Published var name: String?
    @Published var addedDate: Date?
    @Published var modifiedDate: Date?
    @Published var createdDate: Date?
    @Published var appURL: URL
    @Published var childIcons: [AnyHashable]?
    @Published var originalFolderIcon: NSImage?
    @Published var children = [AppEntry]()
    @Published var directoryEntry: AppEntry?
    @Published var iconDictionary: [String: NSImage]?
    @Published var icons: [NSImage]?
    @Published var appImage: NSImage?
    @Published var originalImage: NSImage?
    @Published var attributes: [FileAttributeKey: Any] = [:]
    @Published var xattr: XATTR?
    @Published var exposedFiles: [Int] = []
    @Published var processedURLs = Set<URL>()
    @Published var isSelected: Bool = false
    
    @MainActor var isSpecial: Bool {
        let path = appURL.path
        let iconPath = NSString.path(withComponents: [path, "Icon\r"])
        let exists = filemanager.fileExists(atPath: iconPath)
        return exists
    }

    var isLeaf: Bool {
        let fileType = attributes[FileAttributeKey.type] as! String

        if fileType == "NSFileTypeDirectory" {
            return false // folders are not leafs
        }
        if fileType == "NSFileTypeSymbolicLink" {
            return false // symlinks can't be a leaf for now
        }
        if appURL.pathExtension == "app" {
            return false // nor are Apps
        }
        return true
    }

    var isApp: Bool {
        let isAnApp = workspace.isFilePackage(atPath: appURL.path)
        let wasAnApp = hasValidMacOSApplication(contentsURL: appURL)
        return isAnApp || wasAnApp
    }

    var canAccess: Bool {
        let result1 = filemanager.isWritableFile(atPath: appURL.path())
        var result2 = false
        do {
            result2 = try appURL.checkResourceIsReachable()
        } catch {
            symlog.error("checkResourceIsReachable: FAIL")
        }
        //        if !result1 || !result2 {
        //            symlog.warning("no access: \(String(describing: appURL?.absoluteString)) writeable: \(result1) reachable: \(result2)")
        //        }
        return result1 && result2
    }

    var hasCustomIcon: Bool {
        let customIconURL = appURL.appendingPathComponent(CUSTOM_ICON_NAME)
        let result = filemanager.fileExists(atPath: customIconURL.path)
        return result
    }

    var hasMyCustomIcon: Bool {
        if let xattr = xattr {
            do {
                // Check if the old attribute exists and remove it
                if xattr.hasAttribute(CUSTOM_ICON_ID_OLD) {
                    try xattr.removeXattr(name: CUSTOM_ICON_ID_OLD)
                }
            } catch let error as NSError {
                symlog.error("Error setting xattr: \(error)")
            }
        }

        return xattr?.hasAttribute(CUSTOM_ICON_ID) ?? false
    }

    var skipDescendents: Bool {
        let result = isFolder && (children.count > 0)
        return result
    }

    var isFolder: Bool {
        let fileType = attributes[FileAttributeKey.type] as? String
        if fileType == "NSFileTypeSymbolicLink" {
            return false // symlinks can't be a folder for now
        }
        return (fileType == "NSFileTypeDirectory") ? true : false
    }

    // Add a nested struct for Codable conformance
    struct CodableRepresentation: Codable {
        let id: UUID
        let name: String?
        let appURL: URL
    }

    private init(id: UUID, name: String?, appURL: URL, cachedHash: Int) {
        self.id = id
        self.name = name
        self.appURL = appURL
        self.cachedHash = cachedHash
        childIcons = []
        originalFolderIcon = nil
        children = []
        directoryEntry = nil
        iconDictionary = [:]
        icons = []
        appImage = nil
        originalImage = nil
        attributes = [:]
        xattr = nil
        processedURLs = Set<URL>()
        isSelected = false
        addedDate = nil
        modifiedDate = nil
        createdDate = nil
        super.init()
        collectEntries()
    }

    convenience init(from representation: CodableRepresentation) {
        self.init(id: representation.id, name: representation.name, appURL: representation.appURL, cachedHash: representation.id.hashValue)
    }

    @MainActor
    func nonisolatedEncode() -> CodableRepresentation {
        return CodableRepresentation(id: id, name: name, appURL: appURL)
    }

    class func root() -> AppEntry? {
        let root = self.init(withURL: URL(fileURLWithPath: "/"))
        return root
    }

    required init(withURL url: URL) {
        appURL = url
        cachedHash = UUID().hashValue // Use a new UUID for the hash
        super.init()
        collectEntries()
    }

    func encode(to encoder: Encoder) throws {
        let representation = CodableRepresentation(id: id, name: name, appURL: appURL)
        try representation.encode(to: encoder)
    }

    override nonisolated var hash: Int {
        return cachedHash
    }

    static func == (lhs: AppEntry, rhs: AppEntry) -> Bool {
        return lhs.id == rhs.id
    }

    private let cachedHash: Int

    func isAppFolder() -> Bool {
        let appFolderSettings = AppData.shared.appFolders

        for folder in appFolderSettings {
            if appURL == folder.url.standardized {
                return true
            }
        }
        return false
    }

    func getUniqueIdentifier(for url: URL) -> UInt64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            // The NSFileSystemFileNumber key corresponds to the inode number
            if let fileSystemNumber = attributes[.systemFileNumber] as? NSNumber {
                return fileSystemNumber.uint64Value
            }
        } catch {
            symlog.error("Error retrieving file attributes: \(error)")
        }
        return nil
    }

    func setCustomAttribute(for entry: AppEntry, index: Int) {
        let attributeName = CUSTOM_ATTRIBUTES + ".f" + String(index)
        let attributeValue = getUniqueIdentifier(for: entry.appURL)

        do {
            // Convert UInt64? to Data
            if let value = attributeValue {
                let data = withUnsafeBytes(of: value) { Data($0) }
                try entry.xattr?.setXattr(name: attributeName, value: data)
            } else {
                // Handle the case where attributeValue is nil
                symlog.error("Failed to get unique identifier for \(entry.name ?? "")")
            }
        } catch let error as NSError {
            if error.code == 13 { // Operation not permitted
                // Ask for admin permission
                if askPermission(entry.appURL) {
                    // Retry setting the attribute
                    do {
                        if let value = attributeValue {
                            let data = withUnsafeBytes(of: value) { Data($0) }
                            try entry.xattr?.setXattr(name: attributeName, value: data)
                        }
                    } catch {
                        symlog.error("Error setting custom attribute after permission for \(entry.name ?? ""): \(error)")
                    }
                } else {
                    symlog.error("Permission denied for setting custom attribute for \(entry.name ?? "")")
                }
            } else {
                symlog.error("Error setting custom attribute for \(entry.name ?? ""): \(error)")
            }
        }
    }

    // Modify the askPermission function to actually request permission
    // Modify the askPermission function to handle AppleScript execution safely
    func askPermission(_ url: URL) -> Bool {
        let script = """
        do shell script "sudo touch '\(url.path)'"
        """

        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?

        // Use optional binding to safely execute the AppleScript
        if let _ = appleScript?.executeAndReturnError(&error) {
            return true
        } else if let error = error {
            symlog.error("Error requesting permission: \(error)")
            return false
        } else {
            symlog.error("Unknown error occurred while requesting permission")
            return false
        }
    }

    @MainActor
    func collectEntries() {
//        Task {
            let fm = FileManager()
            do {
                attributes = try fm.attributesOfItem(atPath: appURL.path)
            } catch {
                symlog.error("attributes: FAIL")
            }
            xattr = XATTR(path: appURL.path(), options: XATTROptions.nofollow)
            if let xattr = xattr {
                for attrName in xattr.attributes {
                    if attrName.starts(with: CUSTOM_ATTRIBUTES) {
                        do {
                            // Use optional binding for attrData
                            let attrData = try xattr.getXattr(name: attrName)
                            if let attrString = String(data: attrData, encoding: .utf8),
                               let intValue = Int(attrString) {
                                exposedFiles.append(intValue)
                            }
                        } catch {
                            symlog.error("Error reading xattr \(attrName): \(error)")
                        }
                    }
                }
            }
            // Rest of the function remains unchanged
            name = appURL.lastPathComponent
            createdDate = attributes[FileAttributeKey.creationDate] as? Date
            modifiedDate = attributes[FileAttributeKey.modificationDate] as? Date
            addedDate = attributes[FileAttributeKey.creationDate] as? Date
            name = appURL.lastPathComponent
            createdDate = attributes[FileAttributeKey.creationDate] as? Date
            modifiedDate = attributes[FileAttributeKey.modificationDate] as? Date
            addedDate = attributes[FileAttributeKey.creationDate] as? Date
            
            originalImage = workspace.icon(for: UTType.folder)
            if isApp {
                originalImage = workspace.icon(forFile: appURL.path)
                originalImage?.size = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
                appImage = originalImage
            } else if isFolder {
                if hasMyCustomIcon {
                    originalImage = getCustomFolderIcon(folderURL: appURL)
                    originalImage?.size = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
                } else {
                    originalImage = workspace.icon(forFile: appURL.path)
                    originalImage?.size = NSMakeSize(CGFloat(ICON_SIZE), CGFloat(ICON_SIZE))
                }
                appImage = originalImage
                // Check if the folder is a special folder
                
                if !isSpecial && !isAppFolder() {
                    children = []
                    scanURL()
                    if (children.count) != 0 {
                        appImage = composeIcons()
                        let ws = NSWorkspace.shared
                        if !ws.setIcon(appImage, forFile: appURL.path, options: []) {
                            symlog.error("Failed to set icon on: \(appURL)")
                        }
                        symlog.value("Folder \(String(describing: name)) created with \(children.count) child entries")
                        for (index, childEntry) in children.enumerated() {
                            setCustomAttribute(for: childEntry, index: index)
                        }
                    }
                }
            }
            
            if let iconImage = appImage {
                iconDictionary = [
                    KEY_IMAGE: iconImage]
            }
//        }
    }

    /// Looks in the directoryToScan items which are directories or packages. If found an entry is created and checked if it is an application.
    /// If so, the entry is added as a child entry. If the item was a package, no further recursion is needed as packages are not applications per say.
    /// The folder being scanned is limited by the value in MAX_LEVEL
    @MainActor
    func scanURL() {
//        Task {
            let fm = FileManager.default
            let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey, .isPackageKey, .customIconKey])
            let directoryEnumerator = fm.enumerator(at: appURL, includingPropertiesForKeys: Array(resourceKeys), options: [.skipsHiddenFiles, .skipsPackageDescendants])!
            
            while let fileURL = directoryEnumerator.nextObject() as? URL {
                // Retrieve the directory property
                guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                      let isDirectory = resourceValues.isDirectory,
                      let isPackage = resourceValues.isPackage
                else {
                    continue
                }
                if isDirectory {
                    let entry = AppEntry(withURL: fileURL)
                    if !children.contains(where: { $0.appURL == entry.appURL }) {
                        children.append(entry)
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
//            }
        }
    }

    func getCustomFolderIcon(folderURL: URL) -> NSImage? {
        // Get the icon for the folder
        let icon = workspace.icon(forFile: folderURL.path)

        // Check if the icon is custom (not the default folder icon)
        if icon.isValid {
            if let folderUTType = UTType(filenameExtension: "folder") {
                let defaultFolderIcon = workspace.icon(for: folderUTType)
                if !icon.isEqual(defaultFolderIcon) {
                    return icon
                }
            }
        }

        // If no custom icon found, check for the "Icon\r" file
        let iconFileName = "Icon\r"
        let iconFileURL = folderURL.appendingPathComponent(iconFileName)

        if filemanager.fileExists(atPath: iconFileURL.path) {
            // If "Icon\r" file exists, get its icon
            return workspace.icon(forFile: iconFileURL.path)
        }

        return nil
    }

    // Helper function to convert a string to fourCharCode
    func fourCharCode(from string: String) -> FourCharCode {
        return string.utf8.reduce(0) { ($0 << 8) + FourCharCode($1) }
    }

    class func scanApplications(atPath: String?, currentDirectory: String?) -> [AppEntry] {
        var entries: [AppEntry] = []

        guard let currentDir = atPath ?? currentDirectory else { return entries }

        do {
            let keys = [URLResourceKey.nameKey, URLResourceKey.isDirectoryKey, URLResourceKey.isPackageKey]
            let contents = try filemanager.contentsOfDirectory(at: URL(fileURLWithPath: currentDir), includingPropertiesForKeys: keys, options: .skipsHiddenFiles)

            for item in contents {
                if item.path.hasSuffix("Applications") || item.path.hasSuffix(".Trash") { continue }
                let directoryEntry = AppEntry(withURL: item)
                entries.append(directoryEntry)
            }
        } catch {
            symlog.error("Error scanning directory: \(error)")
        }
        return entries
    }

    func hasValidMacOSApplication(contentsURL: URL) -> Bool {
        let fileManager = FileManager.default

        // Check for Info.plist
        let infoPlistURL = contentsURL.appendingPathComponent("Info.plist")
        guard fileManager.fileExists(atPath: infoPlistURL.path) else {
            return false
        }

        // Check for MacOS folder and executable
        let macOSFolderURL = contentsURL.appendingPathComponent("MacOS")
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: macOSFolderURL.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return false
        }

        // Check for at least one file in MacOS folder (the executable)
        do {
            let macOSContents = try fileManager.contentsOfDirectory(at: macOSFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            guard !macOSContents.isEmpty else {
                return false
            }
        } catch {
            return false
        }

        // Check for Resources folder
        let resourcesFolderURL = contentsURL.appendingPathComponent("Resources")
        isDirectory = false
        guard fileManager.fileExists(atPath: resourcesFolderURL.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return false
        }

        // All minimum requirements are met
        return true
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
            reducer?.setSharpensImage(true)
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

    // Add this function to the AppEntry class

    func applyIcons(collectionView: NSCollectionView, contentArray: [AppEntry]) {
        let indexes = collectionView.selectionIndexes
        if indexes.count > 0 {
            let tempContentArray = indexes.compactMap { contentArray[safe: $0] }
            let tempArray = tempContentArray.compactMap { entry -> AppEntry? in
                guard entry.canAccess else {
                    symlog.warning("Skipping non-accessible url: \(entry.appURL.path)")
                    return nil
                }

                guard entry.iconDictionary != nil else {
                    symlog.warning("iconDictionary nil for: \(entry.appURL.path)")
                    return nil
                }

                let original = entry.originalImage
                let current = entry.appImage
                if current != original {
                    symlog.info("Setting icon on: \(entry.appURL)")
                    return entry
                }
                return nil
            }

            let ws = NSWorkspace.shared
            for entry in tempArray {
                let aURL = entry.appURL
                // Handle the throwing function and unwrap the optional
                if let xattr = entry.xattr {
                    do {
                        try xattr.setXattr(name: CUSTOM_ICON_ID, value: Data())
                    } catch let error as NSError {
                        if error.code == 13 {
                            // Show ask permission
                            if askPermission(entry.appURL) {
                                // Try again after permission
                                try? xattr.setXattr(name: CUSTOM_ICON_ID, value: Data())
                            }
                        } else {
                            print("Error setting xattr: \(error)")
                        }
                        // Delete attribute if setting failed
                        try? xattr.removeXattr(name: CUSTOM_ICON_ID)
                    }
                }
                // Set the icon using NSWorkspace
                if !ws.setIcon(entry.appImage, forFile: aURL.path, options: []) {
                    symlog.error("Failed to set icon on: \(aURL)")
                }
            }
        }
        collectionView.selectionIndexes = IndexSet()
    }


    func pathWithName() -> String? {
        let path = URL(fileURLWithPath: appURL.path).appendingPathComponent(name ?? "").path
        return isLeaf ? path : path + "/"
    }

    func compare(_ other: AppEntry?) -> ComparisonResult {
        return name?.localizedCaseInsensitiveCompare(other?.name ?? "") ?? ComparisonResult.orderedSame
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
        var folderIcon = workspace.icon(for: UTType.folder)
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
