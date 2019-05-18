//
//  ExampleItem.swift
//  Metal
//
//  Created by JGL on 2018/7/14.
//  Copyright © 2018 JGL. All rights reserved.
//

import Cocoa

class ExampleItem: NSCollectionViewItem, ReuseItem {

    @IBOutlet weak var nameLabel: NSTextField!
    var exmple: Example! {
        didSet {
            nameLabel.stringValue = exmple.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.labelColor.cgColor
        view.layer?.cornerRadius = 5
        view.layer?.borderWidth = 3
        // Do view setup here.
    }
    
}
