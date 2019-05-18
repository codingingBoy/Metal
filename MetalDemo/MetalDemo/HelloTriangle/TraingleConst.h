//
//  TraingleConst.h
//  MetalDemo
//
//  Created by JGL on 2018/7/21.
//  Copyright © 2018 JGL. All rights reserved.
//

#ifndef TraingleConst_h
#define TraingleConst_h

#include <simd/simd.h>

//struct TriangleVertex {
//    let position: vector_float2
//    let color: vector_float4
//
//    init(position: vector_float2, color: vector_float4) {
//        self.position = position
//        self.color = color
//    }
//}
//
//struct TriangleConst {
//    static let inputVerticesIndex = 0
//    static let inputViewportIndex = 1
//}

struct TriangleVertex {
    vector_float4 color;
    vector_float2 position;
};

typedef enum AAPLVertexInputIndex
{
    AAPLVertexInputIndexVertices     = 0,
    AAPLVertexInputIndexViewportSize = 1,
} AAPLVertexInputIndex;

#endif /* TraingleConst_h */
