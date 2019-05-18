//
//  ComputeViewController.swift
//  MetalDemo
//
//  Created by JGL on 2018/8/18.
//  Copyright © 2018 JGL. All rights reserved.
//

import Cocoa
import Metal
import MetalKit


class ComputeViewController: NSViewController {

    let mtlView = MTKView.init()
    var renderer: ComputeRenderer!

    override func loadView() {
        view = mtlView
        guard let device = MTLCreateSystemDefaultDevice() else {
            return
        }
        mtlView.device = device
        renderer = ComputeRenderer.init(device: device)
        mtlView.autoresizingMask = [.width, .height]
        mtlView.delegate = renderer

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        renderer.mtkView(mtlView, drawableSizeWillChange: view.frame.size)
        // Do view setup here.
    }
    
}
