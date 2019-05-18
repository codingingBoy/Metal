//
//  CubeRender.swift
//  MetalDemo
//
//  Created by JGL on 2018/10/28.
//  Copyright © 2018 JGL. All rights reserved.
//

import Foundation
import MetalKit

public class CubeRenderer:NSObject, MTKViewDelegate, Render {
    var size: CGSize = .zero
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    let renderPipeline: MTLRenderPipelineState
    var uniformBuffer: MTLBuffer!
    var rotation: Float = 0

    var indexBuffer: MTLBuffer!
    var vertexBuffer: MTLBuffer!
    let indexData: [UInt16] =
        [0, 1, 2, 2, 3, 0,   // front
        1, 5, 6, 6, 2, 1,   // right
        3, 2, 6, 6, 7, 3,   // top
        4, 5, 1, 1, 0, 4,   // bottom
        4, 0, 3, 3, 7, 4,   // left
        7, 6, 5, 5, 4, 7   // back
    ]
    
    required init?(device: MTLDevice) {
        
        self.device = device
        guard let queue = device.makeCommandQueue(),
            let library = device.makeDefaultLibrary() else {
                return nil
        }
        commandQueue = queue
        let pipelineDescriptor = MTLRenderPipelineDescriptor.init()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertex_cube")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragment_cube")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        guard let renderPipeline = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            return nil
        }
        self.renderPipeline = renderPipeline
        super.init()
        
        initBuffer()
    }
    
    
    private func initBuffer() {
        let points: [vector_float4] = [[-1.0, -1.0,  1.0, 1.0],
                                       [ 1.0, -1.0,  1.0, 1.0],
                                       [ 1.0,  1.0,  1.0, 1.0],
                                       [-1.0,  1.0,  1.0, 1.0],
                                       [-1.0, -1.0, -1.0, 1.0],
                                       [ 1.0, -1.0, -1.0, 1.0],
                                       [ 1.0,  1.0, -1.0, 1.0],
                                       [-1.0,  1.0, -1.0, 1.0]]
        
        let colors: [vector_float4] = [[1, 0, 0, 1],
                                       [0, 1, 0, 1],
                                       [0, 0, 1, 1],
                                       [1, 1, 1, 1],
                                       [0, 0, 1, 1],
                                       [1, 1, 1, 1],
                                       [1, 0, 0, 1],
                                       [0, 1, 0, 1]
        ]
        let vertexs = Array(0..<points.count).map{Vertex.init(position: points[$0], color: colors[$0])}
        
        vertexBuffer = device.buffer(vertexs)
        indexBuffer = device.buffer(indexData)
        uniformBuffer = device.makeBuffer(length: MemoryLayout<matrix_float4x4>.size, options: [])
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size
    }
    
    
    public func draw(in view: MTKView) {

        update()
        guard let buffer = commandQueue.makeCommandBuffer(),
            let renderPassDescriptor =  view.currentRenderPassDescriptor,
            let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
            let drawable = view.currentDrawable else {
                return
        }
        let size = MTLViewport.init(size: self.size)
        encoder.setViewport(size)
        encoder.setRenderPipelineState(renderPipeline)
        encoder.setFrontFacing(.counterClockwise)
        encoder.setCullMode(.back)

        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        encoder.drawIndexedPrimitives(type: .triangle,
                                      indexCount: indexData.count,
                                      indexType: .uint16,
                                      indexBuffer: indexBuffer,
                                      indexBufferOffset: 0)
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


