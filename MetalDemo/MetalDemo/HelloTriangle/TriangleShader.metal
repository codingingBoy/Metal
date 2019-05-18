//
//  TriangleShader.metal
//  MetalDemo
//
//  Created by JGL on 2018/7/21.
//  Copyright © 2018 JGL. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct Vertex {
    float4 clipSpacePosition [[position]];
    float4 color;
};

vertex Vertex
vertexShader(uint vertexId [[vertex_id]],
             constant Vertex *vertexs [[buffer(0)]],
             constant vector_uint2 *viewport [[buffer(1)]]) {
    Vertex out;

    out.clipSpacePosition.xy = vertexs[vertexId].clipSpacePosition.xy;
    out.color = vertexs[vertexId].color;
    return out;
}

fragment float4 fragmentShader(Vertex in [[stage_in]]) {
    return in.color;
}
