//
//  TriangleRenderer.swift
//  MetalDemo
//
//  Created by JGL on 2018/7/21.
//  Copyright © 2018 JGL. All rights reserved.
//

import Cocoa
import MetalKit

class TriangleRenderer: NSObject, MTKViewDelegate, Render {
    

    let device: MTLDevice?
    var viewSize: vector_uint2 = vector2(0, 0)
    let commandQueue: MTLCommandQueue?
    var pipeline: MTLRenderPipelineState!
    
    required init?(device: MTLDevice) {
        
        self.device = device
        self.commandQueue = device.makeCommandQueue()
        super.init()
        
        let library = device.makeDefaultLibrary()
        let descriptor = MTLRenderPipelineDescriptor.init()
        descriptor.vertexFunction = library?.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        guard let pipeline = try? device.makeRenderPipelineState(descriptor: descriptor) else {
            return
        }
        self.pipeline = pipeline
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewSize.x = uint(size.width)
        viewSize.y = uint(size.height)
    }
    
    func draw(in view: MTKView) {
        
        guard let buffer = commandQueue?.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor),
            let drawable = view.currentDrawable else {
            return
        }
        
        let viewport = MTLViewport.init(originX: 0, originY: 0,
                                        width: Double(viewSize.x), height: Double(viewSize.y),
                                        znear: -1, zfar: 1)
        encoder.setViewport(viewport)
        

        let vertices = [(250, -250), (-250, -250), (0, 250)].map {float4.init($0.0/500.0, $0.1/500.0, 1, 1)}
        
        let rgbas = [(1, 0, 0, 1),
                     (0, 1, 0, 1),
                     (0, 0, 1, 1)].map {float4.init($0.0, $0.1, $0.2, $0.3)}
        let vertexs = (0..<vertices.count).map {Vertex.init(position: vertices[$0], color: rgbas[$0])}

        let dataSize = vertices.count * MemoryLayout<Vertex>.size
        let vertexBuffer = device!.makeBuffer(bytes: vertexs, length: dataSize, options: [])
        encoder.setVertexBuffer(vertexBuffer!, offset: 0, index: 0)

        encoder.setRenderPipelineState(pipeline)

//        let pointer: UnsafeMutablePointer<float2> = UnsafeMutablePointer.init(mutating: vertices)
        
        encoder.setVertexBytes(&viewSize, length: MemoryLayout.size(ofValue: viewSize), index: 1)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
        
    }
    var fancyColor: (red: Double, green: Double, blue: Double, alpha: Double) {
        return (Double(arc4random()%255)/255.0,
                Double(arc4random()%255)/255.0,
                Double(arc4random()%255)/255.0,
                1)
    }


}
