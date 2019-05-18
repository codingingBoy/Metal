//
//  CommandRenderer.swift
//  Metal
//
//  Created by JGL on 2018/7/14.
//  Copyright © 2018 JGL. All rights reserved.
//

import Cocoa
import Metal
import MetalKit



class CommandRenderer: NSObject, MTKViewDelegate, Render {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    
    required init?(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        super.init()

    }
    
    var fancyColor: (red: Double, green: Double, blue: Double, alpha: Double) {
        return (Double(arc4random()%255)/255.0,
                Double(arc4random()%255)/255.0,
                Double(arc4random()%255)/255.0,
                1)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

        
    }
    
    func draw(in view: MTKView) {
        view.clearColor = MTLClearColor.init(red: fancyColor.red,
                                             green: fancyColor.blue,
                                             blue: fancyColor.blue,
                                             alpha: fancyColor.alpha)
        let commandBuffer = commandQueue?.makeCommandBuffer()
        guard let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        /**
         custom render command
         */
        
        encoder?.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    

}
