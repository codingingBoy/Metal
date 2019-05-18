//
//  Wheels.swift
//  MetalDemo
//
//  Created by JGL on 2018/10/26.
//  Copyright © 2018 JGL. All rights reserved.
//

import Foundation
import MetalKit

public extension MTLViewport {
    init(size: CGSize) {
        self.init()
        width = Double(size.width)
        height = Double(size.height)
    }
}

extension MTLDevice {
    func buffer<T>(_ vertexs: [T]) -> MTLBuffer? {
        return makeBuffer(bytes: vertexs, length: MemoryLayout<T>.size * vertexs.count, options: [])
    }
    
    func library(for name: String) -> MTLLibrary? {
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
    
    func texture(fileName: String) -> MTLTexture? {
        guard let path = Bundle.main.pathForImageResource(NSImage.Name.init("forest")),
            let image = NSImage.init(contentsOfFile: path) else { return nil }
        return texture(image: image)
    }

    func texture(color: UInt32, size: CGSize) -> MTLTexture? {
        let image = NSImage.init(size: size)
        let imageColor = NSColor.red
        image.lockFocus()
        imageColor.drawSwatch(in: NSRect.init(origin: .zero, size: size))
        image.unlockFocus()
        return texture(image: image)
    }
    
    func texture(imageName: String) -> MTLTexture? {
        guard let image = NSImage.init(named: NSImage.Name.init(imageName)) else { return nil }
        return texture(image: image)
    }
    
    func texture(image: NSImage) -> MTLTexture? {

        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        let loader = MTKTextureLoader.init(device: self)
        do {
            let t = try loader.newTexture(cgImage: cgImage, options: [.textureUsage : MTLTextureUsage.shaderRead.rawValue])
            return t
        } catch {
            print(error)
            return nil
        }
        
        
//         try? loader.newTexture(cgImage: cgImage, options: [.textureUsage : MTLTextureUsage.shaderRead.rawValue])
    }
    
    func outputTexture(for input: MTLTexture) -> MTLTexture? {
        let textureDescriptor = MTLTextureDescriptor.init()
        textureDescriptor.width = input.width
        textureDescriptor.height = input.height
        textureDescriptor.usage = .shaderReadWrite

        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.textureType = input.textureType
        return makeTexture(descriptor: textureDescriptor)
    }
    
    var rectagleIndexBuffer: MTLBuffer? {
        let index: [uint16] = [0,1,2,2,3,0]
        return buffer(index)
    }
    
    
}

extension MTLTextureUsage {
    public static var shaderReadWrite: MTLTextureUsage {
        let usage = (MTLTextureUsage.shaderRead.rawValue) | (MTLTextureUsage.shaderWrite.rawValue)
        return MTLTextureUsage.init(rawValue: usage)
    }
}

extension MTLRegion {
    init(size: CGSize) {
        self.init()
        self.size.width = Int(size.width)
        self.size.height = Int(size.height)
        self.size.depth = 1
    }
}

extension NSColor {
    convenience init(rgba: UInt32) {
        let color = Array(0..<4).map { (i: Int) -> CGFloat in
            let j = i * 8
            let k = rgba & (0xf000>>j)
            return CGFloat(k >> (32-j)) / 255.0
        }
        self.init(red: color[0], green: color[1], blue: color[2], alpha: color[3])
    }
    
    convenience init(rgb: UInt32, alpha: Float = 1) {
        let a = UInt32(alpha * 255)
        let rgba = (rgb >> 8) + a
        self.init(rgba: rgba)
    }
}
