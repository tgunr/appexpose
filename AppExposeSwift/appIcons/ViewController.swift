//
//  ViewController.swift
//  appIcons
//
//  Created by Dave Carlton on 6/26/16.
//  Copyright © 2016 Dave Carlton. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var collectionView: NSCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.collectionView.itemPrototype = self.storyboard?.instantiateController(withIdentifier: "collectionViewItem")
//            as! NSCollectionViewItem
    }
    

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

