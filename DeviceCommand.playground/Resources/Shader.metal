
#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

vertex Vertex
vertex_triangle(uint vertexId [[vertex_id]],
            constant Vertex *vertexs [[buffer(0)]],
            constant Uniforms &uniforms [[buffer(1)]]) {
    return vertexs[vertexId];
}

fragment float4 fragment_triangle(Vertex in [[stage_in]]) {
    return in.color;
}
