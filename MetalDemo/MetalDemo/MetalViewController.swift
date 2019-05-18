//
//  MetalViewController.swift
//  MetalDemo
//
//  Created by JGL on 2018/10/30.
//  Copyright © 2018 JGL. All rights reserved.
//

import Cocoa
import MetalKit

protocol Render: MTKViewDelegate {
    init?(device: MTLDevice)    
}

class MetalViewController: NSViewController {
    
    var render: MTKViewDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else { return }
        let view = MTKView.init(frame: self.view.frame, device: device)
        view.autoresizingMask = [.width, .height]
        view.device = device
        view.delegate = render
        self.view.addSubview(view)
        // Do view setup here.
    }
}
