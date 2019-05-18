//
//  FilterRender.swift
//  MetalDemo
//
//  Created by JGL on 2018/11/21.
//  Copyright © 2018 JGL. All rights reserved.
//

import Foundation
import MetalKit

class FilterRender: NSObject, Render {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let pipeline: MTLRenderPipelineState
    var size = CGSize.zero

//    let computePipeline: MTLComputePipelineState
    
    let inputTexture: MTLTexture
//    let filterTexture: MTLTexture
//    let outputTexture: MTLTexture
    
    let vertexs: [TextureVertex]
    let vertexBuffer: MTLBuffer?
    
    
    required init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue(),
            let library = device.makeDefaultLibrary() else { return nil }
        
        commandQueue = queue
        let descriptor = MTLRenderPipelineDescriptor.init()
        descriptor.vertexFunction = library.makeFunction(name: "filter_vertex")
        descriptor.fragmentFunction = library.makeFunction(name: "filter_fragment")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        guard let pipeline = try? device.makeRenderPipelineState(descriptor: descriptor),
//            let kernalFunction = library.makeFunction(name: "filter_compute"),
//            let computePipeline = try? device.makeComputePipelineState(function: kernalFunction),
            let inputTexture = device.texture(imageName: "sticker")
//            let filterTexture = device.texture(fileName: "forest"),
//            let outputTexture = device.outputTexture(for: inputTexture)
            else {
                return nil
        }
        
        self.pipeline = pipeline
//        self.computePipeline = computePipeline
        self.inputTexture = inputTexture
//        self.filterTexture = filterTexture
//        self.outputTexture = outputTexture
        
        let width = Float(inputTexture.width)
        let height = Float(inputTexture.height)
        
        let points: [(float2, float2)] =
            [
                ([-width, -height], [0.0, 1.0]),
                ([ width, -height], [1.0, 1.0]),
                ([ width,  height], [1.0, 0.0]),
                ([-width,  height], [0.0, 0.0]),
        ]
        
        vertexs = points.map{
            TextureVertex.init(position: $0.0, textureCoordinate: $0.1)
        }
        vertexBuffer = device.buffer(vertexs)
        super.init()
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size
    }
    
    func draw(in view: MTKView) {

//        view.clearColor = MTLClearColor.init(red: 1, green: 1, blue: 1, alpha: 1)
        guard let buffer = commandQueue.makeCommandBuffer()
//            let computeEncoder = buffer.makeComputeCommandEncoder()
            else { return }
        
//        computeEncoder.setComputePipelineState(computePipeline)
//        computeEncoder.setTexture(inputTexture, index: 0)
//        computeEncoder.setTexture(filterTexture, index: 1)
//        computeEncoder.setTexture(outputTexture, index: 2)
//
//        let w = computePipeline.threadExecutionWidth
//        let h = computePipeline.maxTotalThreadsPerThreadgroup / w
//        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
//        let threadsPerGrid = MTLSize.init(width: (inputTexture.width + w - 1) / w,
//                                          height: (inputTexture.height + h - 1) / h,
//                                          depth: 1)
//        computeEncoder.dispatchThreadgroups(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//        computeEncoder.endEncoding()
        
        guard let descritor = view.currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: descritor),
            let drawable = view.currentDrawable,
            let indexBuffer = device.rectagleIndexBuffer else { return }
        
        encoder.setViewport(MTLViewport.init(size: self.size))
        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        var viewSize = float2.init(Float(self.size.width), Float(self.size.height))
        
        encoder.setVertexBytes(&viewSize, length: MemoryLayout.size(ofValue: viewSize), index: 1)

        encoder.setFragmentTexture(inputTexture, index: 0)
        encoder.setRenderPipelineState(pipeline)

        encoder.drawIndexedPrimitives(type: .triangle, indexCount: 6, indexType: MTLIndexType.uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
    }
    
}

