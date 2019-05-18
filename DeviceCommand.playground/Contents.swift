//: A Cocoa based Playground to present user interface

import AppKit
import PlaygroundSupport
import MetalKit

class CommandRenderer: NSObject, MTKViewDelegate {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    init?(device: MTLDevice?) {
        guard let device = device,
        let queue = device.makeCommandQueue() else { return nil }
        self.device = device
        self.commandQueue = queue
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
        let commandBuffer = commandQueue.makeCommandBuffer()
        guard let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        encoder?.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
    
    
}


let device = MTLCreateSystemDefaultDevice()
let frame = CGRect.init(x: 0, y: 0, width: 400, height: 250)
var renderView = MTKView.init(frame: frame, device: device)
let render = CommandRenderer.init(device: device!)
renderView.preferredFramesPerSecond = 10
renderView.delegate = render

// Present the view in Playground
PlaygroundPage.current.liveView = renderView

