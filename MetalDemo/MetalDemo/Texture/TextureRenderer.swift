//
//  TextureRenderer.swift
//  MetalDemo
//
//  Created by JGL on 2018/7/24.
//  Copyright © 2018 JGL. All rights reserved.
//

import Cocoa
import MetalKit


class TextureRenderer: NSObject, MTKViewDelegate, Render {
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue?
    var pipeline: MTLRenderPipelineState!
    var verticeBuffer: MTLBuffer!
    var texture: MTLTexture!
    var viewSize: vector_uint2 = vector2(0, 0)

    required init?(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        let library = device.makeDefaultLibrary()
        let descriptor = MTLRenderPipelineDescriptor.init()
        descriptor.vertexFunction = library?.makeFunction(name: "vertexTextureShader")
        descriptor.fragmentFunction = library?.makeFunction(name: "samplingShader")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        super.init()
        guard let pipeline = try? device.makeRenderPipelineState(descriptor: descriptor) else {
            return
        }
        self.pipeline = pipeline
        
        initTexture()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewSize.x = uint(size.width)
        viewSize.y = uint(size.height)
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = commandQueue?.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
            let drawable = view.currentDrawable else {
            return
        }
        encoder.setViewport(MTLViewport.init(originX: 0, originY: 0, width: Double(viewSize.x), height: Double(viewSize.y), znear: 0, zfar: 1))

        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(verticeBuffer, offset: 0, index: 0)
        encoder.setVertexBytes(&viewSize, length: MemoryLayout<vector_uint2>.size, index: 1)
        encoder.setFragmentTexture(texture, index: 0)
        
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        encoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    var currentImage: AAPLImage? {
        guard let imageFileLocation = Bundle.main.url(forResource: "Image", withExtension: "tga"),
            let image = AAPLImage.init(tgaFileAtLocation: imageFileLocation) else {
            return nil
        }
        return image
    }
    
    private func initTexture() {
        guard let image = currentImage else {
            return
        }
        let descriptor = MTLTextureDescriptor.init()
        descriptor.width = Int(image.width)
        descriptor.height = Int(image.height)
        
        let region = MTLRegion.init(origin: MTLOrigin.init(),
                                    size: MTLSize.init(width: descriptor.width,
                                                       height: descriptor.height,
                                                       depth: 1))
        guard let texture = device.makeTexture(descriptor: descriptor) else {return}
        self.texture = texture

        texture.replace(region: region,
                        mipmapLevel: 0,
                        withBytes: (image.data as NSData).bytes,
                        bytesPerRow: Int(image.width*4))
        let length = MemoryLayout<TextureVertex>.size * vertices.count
        guard let buffer = device.makeBuffer(bytes: vertices, length: length, options: .storageModeShared) else {
            return
        }
        verticeBuffer = buffer
    }
    
    
    var vertices: [TextureVertex] {
        let points: [(vector_float2, vector_float2)] =
            [([ 250.0, -250.0], [1.0, 0.0]),
             ([-250.0, -250.0], [0.0, 0.0]),
             ([-250.0,  250.0], [0.0, 1.0]),
             
             ([ 250.0, -250.0], [1.0, 0.0]),
             ([-250.0,  250.0], [0.0, 1.0]),
             ([ 250.0,  250.0], [1.0, 1.0])
        ]
        return points.map {TextureVertex.init(position: $0, textureCoordinate: $1)}
    }
}
