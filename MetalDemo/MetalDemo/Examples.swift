//
//  Examples.swift
//  Metal
//
//  Created by JGL on 2018/7/14.
//  Copyright © 2018 JGL. All rights reserved.
//

import Foundation
import Cocoa
import MetalKit

enum Example: CaseIterable {
    case commandAndDevice
    case triangle
    case texturing
    case compute
    case cube
    case RbikCube
    case filter
    
    var name: String {
        return "\(self)"
    }
    
    var destination: (MTKViewDelegate & NSObject & Render).Type {
        switch self {
        case .commandAndDevice:
            return CommandRenderer.self
            
        case .triangle:
            return TriangleRenderer.self
            
        case .texturing:
            return TextureRenderer.self
            
        case .compute:
            return ComputeRenderer.self
            
        case .cube:
            return CubeRenderer.self
        
        case .RbikCube:
            return RubicCubeShader.self
        case .filter:
            return FilterRender.self
        }
    }
    
}

