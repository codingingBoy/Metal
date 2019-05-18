import Foundation
import MetalKit

public class CubeRender: NSObject, MTKViewDelegate {
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
    
    public init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue(),
            let library = device.library(for: "CubeShader") else {
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
        print(device)
        
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
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setRenderPipelineState(renderPipeline)
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
    
    
}
