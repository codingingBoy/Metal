//
//  CubeShader.metal
//  MetalDemo
//
//  Created by JGL on 2018/10/28.
//  Copyright © 2018 JGL. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};
struct Uniforms {
    float4x4 modelViewProjectionMatrix;
};

vertex Vertex
vertex_cube(uint vertexId [[vertex_id]],
             constant Vertex *vertexs [[buffer(0)]],
             constant Uniforms &uniforms [[buffer(1)]]) {
    float4x4 matrix = uniforms.modelViewProjectionMatrix;
    Vertex in = vertexs[vertexId];
    Vertex out;
    out.position = matrix * float4(in.position);
    out.color = in.color;
    return out;
}

fragment float4 fragment_cube(Vertex in [[stage_in]]) {
    return in.color;
}
