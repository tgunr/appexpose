//
//  ViewController.swift
//  appIcons
//
//  Created by Dave Carlton on 6/26/16.
//  Copyright © 2016 Dave Carlton. All rights reserved.
//

import Cocoa
class IconViewBox: NSBox {
    @IBOutlet var labelField: NSTextField!
    @IBOutlet var imageView: NSImageView!
    var selected = false
    
    @IBAction func iconSelected(_ sender: Any) {
    }
}

class MyScrollView: NSScrollView {
    var backgroundGradient: NSGradient?
}

class MyCollectionView: NSCollectionView {
}

class MyCollectionViewItem: NSCollectionViewItem {
}

class ViewController: NSViewController, NSCollectionViewDelegate {
    var savedAlternateColors: [AnyHashable]?
    var iconViewBox: IconViewBox?
    var images: [AnyHashable]?
    var sortingMode = 0
    var contentArray: [AnyHashable]?
    var url: URL?

    @IBOutlet var collectionView: NSCollectionView!
    @IBOutlet var arrayController: NSArrayController!
    @IBOutlet var scrollView: MyScrollView!
    @IBOutlet var collectionViewItem: NSCollectionViewItem!

    
    override func awakeFromNib() {
        images = [AnyHashable]()
        contentArray = [AnyHashable]()
        
        addObserver(self, forKeyPath: "url", options: [.new, .old], context: nil)
        
        // save this for later when toggling between alternate colors
        savedAlternateColors = collectionView.backgroundColors
                
        collectionView.setDraggingSourceOperationMask(.copy, forLocal: false)
        let indexes = NSIndexSet()
        collectionView.selectionIndexes = indexes as IndexSet
    }

//    - (void)setSortingMode: (NSUInteger) newMode {
//        sortingMode = newMode;
//        NSSortDescriptor *sort = [[NSSortDescriptor alloc]
//                                                    initWithKey: KEY_NAME ascending: (sortingMode == 0)
//                                                       selector: @selector(caseInsensitiveCompare:)];
//        [arrayController setSortDescriptors: [NSArray arrayWithObject: sort]];
//    }
    @objc
    func setSortingMode(newMode: Int) {
        sortingMode = newMode
        
        let sort: NSSortDescriptor = NSSortDescriptor.init(key: KEY_NAME, ascending: sortingMode==0, selector: #selector(NSString.localizedCaseInsensitiveCompare))
        let descriptors = [sort]
        arrayController.sortDescriptors = descriptors
    }

}


