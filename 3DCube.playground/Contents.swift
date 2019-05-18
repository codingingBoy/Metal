//: A Cocoa based Playground to present user interface

import AppKit
import PlaygroundSupport
import MetalKit



let device = MTLCreateSystemDefaultDevice()
let frame = CGRect.init(x: 0, y: 0, width: 400, height: 250)
var renderView = MTKView.init(frame: frame, device: device)
let render = CubeRender.init(device: device!)
renderView.delegate = render
// Present the view in Playground
PlaygroundPage.current.liveView = renderView

