//  Converted to Swift 5.6.1 by Swiftify v5.6.26165 - https://swiftify.com/
/*
     File: MyViewController.swift 
 Abstract: Controls the collection view of icons.
 */

import Cocoa
import PMUtility
import xattr

class IconViewBox: NSBox {
    @IBOutlet var labelField: NSTextField!
    @IBOutlet var imageView: NSImageView!
    var selected = false

    // -------------------------------------------------------------------------------
    //	hitTest:aPoint
    // -------------------------------------------------------------------------------
    override init() {
        super.init()
    }

    override func awakeFromNib() {
        AppDelegate.shared()?.myWindowController.viewController?.iconViewBox = self
    }

    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        // don't allow any mouse clicks for subviews in this NSBox
        AppDelegate.shared()?.selectionChanged()
        selected = true
        return self
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        boxType = .secondary
        borderType = .bezelBorder
    }

    @IBAction func iconSelected(_ sender: Any) {
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MyScrollView: NSScrollView {
    var backgroundGradient: NSGradient?

    override func awakeFromNib() {
        // set up the background gradient for this custom scrollView
        backgroundGradient = NSGradient(
            starting: NSColor(deviceRed: 0.349, green: 0.6, blue: 0.898, alpha: 0.0),
            ending: NSColor(deviceRed: 0.349, green: 0.6, blue: 0.898, alpha: 0.4))
    }

    override func draw(_ rect: NSRect) {
        // draw our special background as a gradient
        backgroundGradient?.draw(in: documentVisibleRect, angle: 90.0)
    }
}

class MyCollectionView: NSCollectionView {
    override func awakeFromNib() {
        setSubviewSize(128.0)
    }

    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        AppDelegate.shared()?.selectionChanged()
        return nil
    }

    override func didAddSubview(_ subview: NSView) {

    }

    override func resizeSubviews(withOldSize oldBoundsSize: NSSize) {

    }

    func setSubviewSize(_ theSubviewSize: CGFloat) {
        maxItemSize = NSMakeSize(theSubviewSize, theSubviewSize)
        minItemSize = NSMakeSize(theSubviewSize, theSubviewSize)
    }
}

class MyCollectionViewItem: NSCollectionViewItem {
    func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }

    override var isSelected: Bool {
        get {
            super.selected
        }
        set(flag) {
            super.isSelected = flag
            (view as? IconViewBox)?.selected = flag
            (view as? IconViewBox)?.needsDisplay = true
        }
    }
}

class MyViewController: NSViewController, NSCollectionViewDelegate {
    @IBOutlet var collectionView: NSCollectionView!
    @IBOutlet var arrayController: NSArrayController!






    var savedAlternateColors: [AnyHashable]?


    private var appDirectory: Any?
    private var rootEntry: AppEntry?

    var iconViewBox: IconViewBox?
    @IBOutlet var scrollView: MyScrollView!
    var images: [AnyHashable]?

    private var _sortingMode = 0
    var sortingMode: Int {
        get {
            _sortingMode
        }
        set(newMode) {
            _sortingMode = newMode
            let sort = NSSortDescriptor(
                key: KEY_NAME,
                ascending: _sortingMode == 0,
                selector: #selector(NSString.caseInsensitiveCompare(_:)))
            arrayController.sortDescriptors = [sort]
        }
    }
    var contentArray: [AnyHashable]?
    @IBOutlet var collectionViewItem: NSCollectionViewItem!
    var url: URL?

    override init() {
        super.init()
    }

    override func awakeFromNib() {
        images = []
        contentArray = []

        addObserver(
            self,
            forKeyPath: "url",
            options: [.new, .old],
            context: nil)

        // save this for later when toggling between alternate colors
        savedAlternateColors = collectionView.backgroundColors

        sortingMode = 0 // icon collection in ascending sort order

        collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)
        let indexes = NSIndexSet()
        collectionView.selectionIndexes = indexes as IndexSet
    }

    func addEntries(_ array: [AnyHashable]?) {
        // This method is called on the main thread when a background read operation has entries to be added to the entry tree and displayed
        for entry in array ?? [] {
            guard let entry = entry as? AppEntry else {
                continue
            }
            entry.add(toRootEntry: rootEntry)
        }
    }

    @objc func setIcon(_ entry: AppEntry?) {
        if let entry = entry {
            let iconDictionary = entry.iconDictionary
            if let iconDictionary = iconDictionary {
                arrayController.addObject(iconDictionary)
                contentArray?.append(entry)
                zoomChanged(CGFloat(DEFAULT_ICON_SIZE))
            } else {
                PMLOG(1, "iconDictionary nil for: %@", entry.appURL?.path)
            }
        }
    }

    @objc func setIcons(_ iconImages: inout [AnyHashable]) {
        var tempArray: [AnyHashable] = []
        for entry in iconImages {
            guard let entry = entry as? AppEntry else {
                continue
            }
            if let entry = entry {
                if entry.isFolder && (entry.childEntries?.count ?? 0) == 1 {
                    entry.badgeAsFolder()
                }

                if !entry.canAccess && !entry.isApp {
                    entry.badgeAsNoAccess()
                }

                let iconDictionary = entry.iconDictionary
                if let iconDictionary = iconDictionary {
                    tempArray.append(iconDictionary)
                } else {
                    PMLOG(1, "iconDictionary nil for: %@", entry.appURL?.path)
                }
            }
        }
        images = tempArray

    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        AppDelegate.shared()?.myWindowController.progressIndicator.isHidden = false
        AppDelegate.shared()?.myWindowController.progressIndicator.startAnimation(self)

        // build our directory contents on a separate thread,
        // some portions are from disk which could get expensive depending on the size
        PMLOG_SetVerbose(PMLogLevelDebug)
        Thread.detachNewThreadSelector(
            #selector(collectFolders(_:)),
            toTarget: self /* we are the target */,
            with: url)
    }

    @objc func collectFolders(_ directoryToScan: URL?) {
        autoreleasepool {
            let fm = FileManager()
            let fileKeys = [.isDirectoryKey, .customIconKey]
            let dirEnumerator = fm.enumerator(
                at: directoryToScan,
                includingPropertiesForKeys: fileKeys,
                options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles,
                errorHandler: nil)

            var tempArray: [AnyHashable] = []
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
                    var isFolder: NSNumber?
                    try? (theURL as NSURL).getResourceValue(&isFolder, forKey: .isDirectoryKey)

                    var isSymLink: NSNumber?
                    try? (theURL as NSURL).getResourceValue(&isSymLink, forKey: .isSymbolicLinkKey)

                    var isPackage: NSNumber?
                    try? (theURL as NSURL).getResourceValue(&isPackage, forKey: .isPackageKey)

                    var customIcon: NSImage?
                    try? (theURL as NSURL).getResourceValue(&customIcon, forKey: .customIconKey)

                    // Ignore files under the app directory
                    if isFolder?.boolValue ?? false {
                        if !isPackage?.boolValue ?? false {
                            let entry = AppEntry(url: theURL)
                            if !(entry?.isApp ?? false) {
                                PMLOG_DEBUG("adding: %@", theURL)
                                performSelector(onMainThread: Selector("setIcon:"), with: entry, waitUntilDone: true)
                                if let entry = entry {
                                    tempArray.append(entry)
                                }
                                dirEnumerator?.skipDescendents()
                            }
                        } else {
                            dirEnumerator?.skipDescendents()
                        }
                    }
                }
            }
            //        [[[[AppDelegate shared] myWindowController] progressIndicator] stopAnimation:self];
            //        [[[[AppDelegate shared] myWindowController] progressIndicator] setHidden:YES];
            performSelector(onMainThread: Selector("setIcons:"), with: tempArray, waitUntilDone: true)
            //        [collectionView setSelectionIndexes:[NSIndexSet indexSet]];
        }
    }

    func read(from aURL: URL?) {
        var entry: AppEntry?
        var entryArray: [AnyHashable] = []

        if let aURL = aURL {
            let fm = FileManager.default
            let path = aURL.path
            var dirItems: [String]? = nil
            do {
                dirItems = try fm.contentsOfDirectory(atPath: path)
            } catch {
            }

            let i = 0
            for item in dirItems ?? [] {
                i += 1
                let itemURL = aURL.appendingPathComponent(item)
                entry = AppEntry(url: itemURL)
                if let entry = entry {
                    entryArray.append(entry)
                }
            }
            addEntries(entryArray)
            setIcons(&entryArray)
        }
    }

    // -------------------------------------------------------------------------------
    //	collectionView:writeItemsAtIndexes:indexes:pasteboard
    //
    //	Collection view drag and drop
    //  User must click and hold the item(s) to perform a drag.
    // -------------------------------------------------------------------------------
    func collectionView(_ cv: NSCollectionView, writeItemsAt indexes: IndexSet, to pasteboard: NSPasteboard) -> Bool {
        var urls: [AnyHashable] = []
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        indexes.enumerate() { [self] idx, stop in
            let dictionary = cv.content[idx] as? [AnyHashable : Any]
            let image = dictionary?[KEY_IMAGE] as? NSImage
            let name = dictionary?[KEY_NAME] as? String
            if image != nil && name != nil {
                let aurl = temporaryDirectoryURL.appendingPathComponent("\(name ?? "").tiff")
                urls.append(aurl)
                if let tiffRepresentation = image?.tiffRepresentation, let url = url {
                    NSData(data: tiffRepresentation).write(to: url, atomically: true)
                }
            }
        }
        if urls.count > 0 {
            pasteboard.clearContents()
            if let urls = urls as? [NSPasteboardWriting] {
                return pasteboard.writeObjects(urls)
            }
            return false
        }
        return false
    }

    func showBeforeAppearance() {
        // get the current scroll position of the document view
        let currentScrollPosition = scrollView.contentView.bounds.origin as? NSPoint
        let indexes = collectionView.selectionIndexes as NSIndexSet
        var tempArray: [AnyHashable] = []
        for entry in contentArray ?? [] {
            guard let entry = entry as? AppEntry else {
                continue
            }
            if let entry = entry {
                var iconDictionary = entry.iconDictionary
                if let iconDictionary = iconDictionary {
                    let original = entry.originalImage
                    let custom = entry.iconImage
                    if custom == original {
                        tempArray.append(iconDictionary)
                    } else {
                        var newDictionary: [AnyHashable : Any]? = nil
                        if let original = original {
                            newDictionary = [
                                KEY_IMAGE : original,
                                KEY_NAME : entry.name ?? ""
                            ]
                        }
                        if let newDictionary = newDictionary {
                            tempArray.append(newDictionary)
                        }
                    }
                } else {
                    PMLOG(1, "iconDictionary nil for: %@", entry.appURL?.path)
                }
            }
        }
        images = tempArray
        collectionView.selectionIndexes = indexes as IndexSet
        collectionView.isSelectable = false
        // restore the scroll location
        scrollView.documentView?.scroll(currentScrollPosition ?? NSPoint.zero)
    }

    func showAfterAppearance() {
        // get the current scroll position of the document view
        let currentScrollPosition = scrollView.contentView.bounds.origin as? NSPoint
        let indexes = collectionView.selectionIndexes as NSIndexSet
        var tempArray: [AnyHashable] = []
        for entry in contentArray ?? [] {
            guard let entry = entry as? AppEntry else {
                continue
            }
            if let entry = entry {
                let iconDictionary = entry.iconDictionary
                if let iconDictionary = iconDictionary {
                    tempArray.append(iconDictionary)
                }
            }
        }
        images = tempArray
        collectionView.selectionIndexes = indexes as IndexSet
        collectionView.isSelectable = true

        // restore the scroll location
        scrollView.documentView?.scroll(currentScrollPosition ?? NSPoint.zero)
    }

    func askPermission(_ url: URL?) -> Bool {
        return false
    }

    func applyIcons() {
        var tempContentArray: [AnyHashable] = []
        var indexes = collectionView.selectionIndexes as NSIndexSet
        if indexes.count != 0 {
            indexes.enumerate({ [self] idx, stop in
                if let object = contentArray?[idx] {
                    tempContentArray.append(object)
                }
            })
            var tempArray: [AnyHashable] = []
            for entry in tempContentArray {
                guard let entry = entry as? AppEntry else {
                    continue
                }
                if let entry = entry {
                    if entry.canAccess {
                        var iconDictionary = entry.iconDictionary
                        if iconDictionary != nil {
                            let original = entry.originalImage
                            let current = entry.iconImage
                            if current != original {
                                PMLOG(1, "Setting icon on: %@", entry.appURL)
                                tempArray.append(entry)
                            }
                        } else {
                            PMLOG(1, "iconDictionary nil for: %@", entry.appURL?.path)
                        }
                    } else {
                        PMLOG(1, "Skipping non-accessible url: %@", entry.appURL?.path)
                    }
                }
            }
            let ws = NSWorkspace.shared
            for entry in tempArray {
                guard let entry = entry as? AppEntry else {
                    continue
                }
                let aURL = entry.appURL
                var ok = entry.setAttribute(CUSTOM_ICON_ID, value: "")
                if !ok {
                    let error = entry.xattr?.resultError()
                    if (error as NSError?)?.code == 13 {
                        // Show ask permission
                        ok = askPermission(entry.appURL)
                    }
                    entry.deleteAttribute(CUSTOM_ICON_ID)
                }
                ok = ws.setIcon(entry.iconImage, forFile: aURL?.path ?? "", options: [])
                if !ok {
                    PMLOG_ERR(1, "Failed to set icon on: %@", url)
                }
            }
        }
        indexes = NSIndexSet()
        collectionView.selectionIndexes = indexes as IndexSet
    }

    func removeIcons() {
        var tempContentArray: [AnyHashable] = []

        var indexes = collectionView.selectionIndexes as NSIndexSet
        if indexes.count != 0 {
            indexes.enumerate({ [self] idx, stop in
                if let object = contentArray?[idx] {
                    tempContentArray.append(object)
                }
            })
            for entry in tempContentArray {
                guard let entry = entry as? AppEntry else {
                    continue
                }
                let aURL = entry.appURL
                let hasCustomIcon = entry.hasAttribute(CUSTOM_ICON_ID)
                if hasCustomIcon {
                    PMLOG(1, "removing CustomIcon: %@", aURL)
                    let customIconURL = aURL?.appendingPathComponent(CUSTOM_ICON_NAME)
                    let fm = FileManager.default
                    var ok = fm.fileExists(atPath: customIconURL?.path ?? "")
                    var error: Error?
                    if ok {
                        do {
                            if let customIconURL = customIconURL {
                                try fm.removeItem(at: customIconURL)
                            }
                        } catch let e {
                            error = e
                        }
                    }
                    ok = entry.deleteAttribute(CUSTOM_ICON_ID)
                    if ok {
                        entry.revertIcon()
                    } else {
                        var error = entry.xattr?.resultError()
                        if (error as NSError?)?.code == 13 {
                            // Show ask permission
                        } else {
                            if let error = error {
                                print("Error: \(error)")
                            }
                        }
                    }
                }
            }
        }
        indexes = NSIndexSet()
        collectionView.selectionIndexes = indexes as IndexSet
    }

    func selectedIcons() -> [AnyHashable]? {
        var tempContentArray: [AnyHashable] = []
        let indexes = collectionView.selectionIndexes as NSIndexSet
        indexes.enumerate({ [self] idx, stop in
            if let object = contentArray?[idx] {
                tempContentArray.append(object)
            }
        })
        return tempContentArray
    }

    override func selectAll(_ sender: Any?) {
        let range = NSRange(0, (contentArray?.count ?? 0))
        let indexes = NSIndexSet(indexesIn: range)
        collectionView.selectionIndexes = indexes as IndexSet

    }

    func selectNone(_ sender: Any?) {
        let indexes = NSIndexSet()
        collectionView.selectionIndexes = indexes as IndexSet
    }

    func zoomChanged(_ newValue: CGFloat) {
        //    NSSize newSize = NSMakeSize(newValue, newValue);
        //    NSRect newRect = NSMakeRect(0.0, 0.0, (newValue + 20), (newValue + 42) );

        //    NSArray *views = [collectionView subviews];
        //    NSView *item = [views objectAtIndex:0];
        //    PMLOG(1,@"frame: %f %f", item.frame.size.width, item.frame.size.height);
        //    PMLOG(1,@"bounds: %f %f", item.bounds.size.width, item.bounds.size.height);

        //    [collectionView setSubviewSize:newValue];
        collectionView.maxItemSize = NSMakeSize(newValue, newValue)
        collectionView.minItemSize = NSMakeSize(newValue, newValue)


        //    for (IconViewBox *box in views) {
        //        [[box imageView] setFrameSize:newSize];
        //        [box setFrameSize:newSize];
        //    }

        //	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        //	for (AppEntry  *entry in contentArray) {
        //		if (entry != nil) {
        //			NSDictionary *iconDictionary = [entry iconDictionary];
        //			if (iconDictionary) {
        //                [[iconDictionary objectForKey:KEY_IMAGE] setSize:newSize];
        //				[[entry iconImage] setSize:newSize];
        //				[[entry originalImage] setSize:newSize];
        //                [tempArray addObject: iconDictionary];
        //			}
        //			else {
        //				PMLOG(1, @"iconDictionary nil for: %@", [[entry appURL] path]);
        //			}
        //		}
        //	}
        //	[self setImages: tempArray];
        //    [[collectionViewItem view] display];
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}