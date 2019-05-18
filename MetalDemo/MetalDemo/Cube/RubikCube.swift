//
//  RubikCube.swift
//  MetalDemo
//
//  Created by JGL on 2018/11/2.
//  Copyright © 2018 JGL. All rights reserved.
//

import Foundation
import MetalKit

class RubicCubeShader: NSObject, Render {
    
    var size: CGSize = .zero
    let device: MTLDevice
    let queue: MTLCommandQueue
    let pipeline: MTLRenderPipelineState

    var vertexBuffer: MTLBuffer!
    var indexBuffer: MTLBuffer!
    var indexData = [UInt16]()
    var uniformBuffer: MTLBuffer!
    var rotation: Float = 0

    
    required init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue(),
            let library = device.makeDefaultLibrary() else {
                return nil
        }
        self.queue = queue
        let vertextFunc = library.makeFunction(name: "vertex_cube")
        let fragmentFunc = library.makeFunction(name: "fragment_cube")
        let descriptor = MTLRenderPipelineDescriptor.init()
        descriptor.vertexFunction = vertextFunc
        descriptor.fragmentFunction = fragmentFunc
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        guard let pipeline = try? device.makeRenderPipelineState(descriptor: descriptor) else {
            return nil
        }
        self.pipeline = pipeline
        super.init()
        initBuffer()
    }

    private func initBuffer() {

        Array(0..<6).map { (i) -> [UInt16] in
            [0 ,1 ,2 ,2, 3, 0].map {UInt16($0 + i*4)}
            }.forEach{indexData.append(contentsOf: $0)}
        

        let point: [vector_float4] = [[-1.0, -1.0,  1.0, 1.0],
                                       [ 1.0, -1.0,  1.0, 1.0],
                                       [ 1.0,  1.0,  1.0, 1.0],
                                       [-1.0,  1.0,  1.0, 1.0],
                                       [-1.0, -1.0, -1.0, 1.0],
                                       [ 1.0, -1.0, -1.0, 1.0],
                                       [ 1.0,  1.0, -1.0, 1.0],
                                       [-1.0,  1.0, -1.0, 1.0]]


        let color = Array(1...6).map {float4.init(Float(($0 & 0x4) >> 2), Float(($0 & 0x2) >> 1), Float(($0 & 0x1)), 1)}
        
        let position = [0, 1, 2, 3,
                     1, 5, 6, 2,
                     3, 2, 6, 7,
                     4, 5, 1, 0,
                     4, 0, 3, 7,
                     7, 6, 5, 4].map {point[$0]}

        
        let vertex = Array(0..<position.count).map {Vertex.init(position: position[$0], color: color[$0/4])}

        vertexBuffer = device.buffer(vertex)
        indexBuffer = device.buffer(indexData)
        uniformBuffer = device.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])

    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size
    }
    
    func draw(in view: MTKView) {
        update()

        guard let buffer = queue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor),
            let drawable = view.currentDrawable else {
                return
        }
        let size = MTLViewport.init(size: self.size)
        encoder.setViewport(size)

        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        encoder.setFrontFacing(.counterClockwise)
        encoder.setCullMode(.back)
        
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        encoder.drawIndexedPrimitives(type: .triangle, indexCount: indexData.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        encoder.endEncoding()
        buffer.present(drawable)
        buffer.commit()
    }
    
    func update() {
        let scaled = scalingMatrix(scale: 0.5)
        rotation += 1 / 100 * Float.pi / 4
        let rotatedY = rotationMatrix(angle: rotation, axis: float3(0, 1, 0))
        let rotatedX = rotationMatrix(angle: Float.pi / 4, axis: float3(1, 0, 0))
        let modelMatrix = matrix_multiply(matrix_multiply(rotatedX, rotatedY), scaled)
        let cameraPosition = vector_float3(0, 0, -3)
        let viewMatrix = translationMatrix(position: cameraPosition)
        let projMatrix = projectionMatrix(near: 0, far: 10, aspect: 1, fovy: 1)
        let modelViewProjectionMatrix = matrix_multiply(projMatrix, matrix_multiply(viewMatrix, modelMatrix))
        let bufferPointer = uniformBuffer.contents()
        
        var uniforms = Uniforms.init(modelViewProjectionMatrix: modelViewProjectionMatrix)
        memcpy(bufferPointer, &uniforms, MemoryLayout<Uniforms>.size)
    }
    
    public struct Uniforms {
        public init(modelViewProjectionMatrix: matrix_float4x4) {
            self.modelViewProjectionMatrix = modelViewProjectionMatrix
        }
        public var modelViewProjectionMatrix: matrix_float4x4
    }
    
    public func translationMatrix(position: float3) -> matrix_float4x4 {
        let X = vector_float4(1, 0, 0, 0)
        let Y = vector_float4(0, 1, 0, 0)
        let Z = vector_float4(0, 0, 1, 0)
        let W = vector_float4(position.x, position.y, position.z, 1)
        return matrix_float4x4(columns:(X, Y, Z, W))
    }
    
    public func scalingMatrix(scale: Float) -> matrix_float4x4 {
        let X = vector_float4(scale, 0, 0, 0)
        let Y = vector_float4(0, scale, 0, 0)
        let Z = vector_float4(0, 0, scale, 0)
        let W = vector_float4(0, 0, 0, 1)
        return matrix_float4x4(columns:(X, Y, Z, W))
    }
    
    public func rotationMatrix(angle: Float, axis: vector_float3) -> matrix_float4x4 {
        var X = vector_float4(0, 0, 0, 0)
        X.x = axis.x * axis.x + (1 - axis.x * axis.x) * cos(angle)
        X.y = axis.x * axis.y * (1 - cos(angle)) - axis.z * sin(angle)
        X.z = axis.x * axis.z * (1 - cos(angle)) + axis.y * sin(angle)
        X.w = 0.0
        var Y = vector_float4(0, 0, 0, 0)
        Y.x = axis.x * axis.y * (1 - cos(angle)) + axis.z * sin(angle)
        Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * cos(angle)
        Y.z = axis.y * axis.z * (1 - cos(angle)) - axis.x * sin(angle)
        Y.w = 0.0
        var Z = vector_float4(0, 0, 0, 0)
        Z.x = axis.x * axis.z * (1 - cos(angle)) - axis.y * sin(angle)
        Z.y = axis.y * axis.z * (1 - cos(angle)) + axis.x * sin(angle)
        Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * cos(angle)
        Z.w = 0.0
        let W = vector_float4(0, 0, 0, 1)
        return matrix_float4x4(columns:(X, Y, Z, W))
    }
    
    public func projectionMatrix(near: Float, far: Float, aspect: Float, fovy: Float) -> matrix_float4x4 {
        let scaleY = 1 / tan(fovy * 0.5)
        let scaleX = scaleY / aspect
        let scaleZ = -(far + near) / (far - near)
        let scaleW = -2 * far * near / (far - near)
        let X = vector_float4(scaleX, 0, 0, 0)
        let Y = vector_float4(0, scaleY, 0, 0)
        let Z = vector_float4(0, 0, scaleZ, -1)
        let W = vector_float4(0, 0, scaleW, 0)
        return matrix_float4x4(columns:(X, Y, Z, W))
    }
    

}
