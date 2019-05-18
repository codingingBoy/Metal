//
//  ReuseItem.swift
//  Metal
//
//  Created by JGL on 2018/7/14.
//  Copyright © 2018 JGL. All rights reserved.
//

import Foundation
import Cocoa

protocol ReuseItem: class {
    
    static var id: String {get}
    static var nibClass: AnyClass {get}
    static var nib: NSNib {get}
}

extension ReuseItem {
    static var id: String {
        
        guard let identifier = NSStringFromClass(self).components(separatedBy: ".").last else {
            fatalError("current class has no prefix ‘Metal.’")
        }
        return identifier
    }
    
    static var reuseId: NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier.init(id)
    }
    
    static var nibClass: AnyClass {
        let className = "Metal.\(id)"
        guard let aClass = NSClassFromString(className) else {
            fatalError("fail to get class from string: \(className)")
        }
        return aClass
    }
    
    static var nib: NSNib {
        return NSNib.init(nibNamed: NSNib.Name.init(id), bundle: nil)!
    }
}
