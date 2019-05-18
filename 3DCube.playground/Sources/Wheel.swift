import Foundation
import MetalKit

public struct Vertex {
    public let position: vector_float4
    public let color: vector_float4
}


public extension MTLViewport {
    public init(size: CGSize) {
        self.init()
        width = Double(size.width)
        height = Double(size.height)
    }
}

public extension MTLDevice {
    public func buffer<T>(_ vertexs: [T]) -> MTLBuffer? {
        return makeBuffer(bytes: vertexs, length: MemoryLayout<T>.size * vertexs.count, options: [])
    }
    
    public func library(for name: String) -> MTLLibrary? {
        guard let libraryPath = Bundle.main.path(forResource: name, ofType: "metal"),
            let content = try? String.init(contentsOfFile: libraryPath, encoding: .utf8) else {
                print("path or content invalid")
                return nil
        }
        if let lib = try? makeLibrary(source: content, options: nil) {
            return lib
        }
        print("library from content fail: /n\(content)")
        return nil
    }
    
}
