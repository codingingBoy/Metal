//
//  ComputeRenderer.swift
//  MetalDemo
//
//  Created by JGL on 2018/8/18.
//  Copyright © 2018 JGL. All rights reserved.
//

import Cocoa
import MetalKit
import Metal

class ComputeRenderer: NSObject, MTKViewDelegate, Render {
    
    
    let device: MTLDevice
    var viewSize: vector_uint2 = vector_uint2.init(0, 0)
    let commandQueue: MTLCommandQueue
    var inTexture: MTLTexture!
    var outTexture: MTLTexture!
    let computePipeline: MTLComputePipelineState!
    let threadsPreGroup = MTLSize.init(width: 16, height: 16, depth: 1)
    var threadGroups: MTLSize!
    var renderPipeline: MTLRenderPipelineState?
    var vertexBuffer: MTLBuffer!
    
    required init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue(),
            let library = device.makeDefaultLibrary(),
            let kernalFunction = library.makeFunction(name: "grayscale"),
            let computePipeline = try? device.makeComputePipelineState(function: kernalFunction) else {
                return nil
        }
        commandQueue = queue
        self.computePipeline = computePipeline
        
        super.init()
        
        initTexture()

        let des = MTLRenderPipelineDescriptor.init()
        des.vertexFunction = library.makeFunction(name: "grayVertexShader")
        des.fragmentFunction = library.makeFunction(name: "graySampleShader")
        des.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipeline  = try? device.makeRenderPipelineState(descriptor: des)
        initVertexBuffer()

    }
    
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewSize.x = uint(size.width)
        viewSize.y = uint(size.height)
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
            return
        }
        computeEncoder.setComputePipelineState(computePipeline)
        computeEncoder.setTexture(inTexture, index: 0)
        computeEncoder.setTexture(outTexture, index: 1)
        computeEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsPreGroup)
        computeEncoder.endEncoding()
        
        guard let renderDes = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderDes),
            let drawable = view.currentDrawable,
            let pipeline = renderPipeline else {
                return
        }
        
        renderEncoder.setViewport(MTLViewport.init(originX: 0, originY: 0, width: Double(viewSize.x), height: Double(viewSize.y), znear: 0, zfar: 1))
        renderEncoder.setRenderPipelineState(pipeline)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&viewSize, length: MemoryLayout<vector_uint2>.size, index: 1)
        renderEncoder.setFragmentTexture(outTexture, index: 0)

        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    

    private static var currentImage: AAPLImage? {
        guard let imageFileLocation = Bundle.main.url(forResource: "Image", withExtension: "tga"),
            let image = AAPLImage.init(tgaFileAtLocation: imageFileLocation) else {
                return nil
        }
        return image
    }
    
    private static var textureDescriptor: MTLTextureDescriptor {
        let des = MTLTextureDescriptor.init()
        guard let image = currentImage else {
            return des
        }
        des.width = Int(image.width)
        des.height = Int(image.height)
        des.usage = .shaderRead
        des.pixelFormat = MTLPixelFormat.bgra8Unorm
        des.textureType = .type2D
        return des
    }
    
    private func initTexture() {
        
        self.inTexture = device.makeTexture(descriptor: ComputeRenderer.textureDescriptor)
        let outDes = ComputeRenderer.textureDescriptor
        let usage = (MTLTextureUsage.shaderRead.rawValue) | (MTLTextureUsage.shaderWrite.rawValue)
        outDes.usage = MTLTextureUsage.init(rawValue: usage)
        guard let outTexture = device.makeTexture(descriptor: outDes) else {
            return
        }
        self.outTexture = outTexture

        let width  = (inTexture.width  + threadsPreGroup.width -  1) / threadsPreGroup.width;
        let height = (inTexture.height + threadsPreGroup.height - 1) / threadsPreGroup.height
        threadGroups = MTLSize.init(width: width, height: height, depth: 1)

        guard let image = ComputeRenderer.currentImage else {
            return
        }
        let region = MTLRegion.init(origin: MTLOrigin.init(), size: MTLSize.init(width: Int(image.width), height: Int(image.height), depth: 1))
        let data = (image.data as NSData).bytes
        let bytesPerRow = 4 * Int(image.width)
        inTexture.replace(region: region, mipmapLevel: 0, withBytes: data, bytesPerRow: bytesPerRow)
    }

    var vertices: [TextureVertex] {
        let data: [((Float, Float), (Float, Float))] =
            [( (  250,  -250 ),  ( 1, 0 ) ),
             ( ( -250,  -250 ),  ( 0, 0 ) ),
             ( ( -250,   250 ),  ( 0, 1 ) ),
             
             ( (  250,  -250 ),  ( 1, 0 ) ),
             ( ( -250,   250 ),  ( 0, 1 ) ),
             ( (  250,   250 ),  ( 1, 1 ) )]
        
        let points = data.map {(vector_float2.init($0.0.0, $0.0.1),
                                vector_float2.init($0.1.0, $0.1.1))}
        
        return points.map {TextureVertex.init(position: $0.0, textureCoordinate: $0.1)}
        
    }

    private func initVertexBuffer() {
        let length = MemoryLayout<TextureVertex>.size * vertices.count
        guard let buffer = device.makeBuffer(bytes: vertices, length: length, options: .storageModeShared) else {
            return
        }
        vertexBuffer = buffer
    }
}
