//
//  TextureRender.metal
//  MetalDemo
//
//  Created by JGL on 2018/8/1.
//  Copyright © 2018 JGL. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

#include "MetalDemo/Foundation/TextureVertex.h"

struct TextureRasterizerData {
    float4 clipSpacePosition [[position]];
    float2 textureCoordinate;
};

vertex TextureRasterizerData
vertexTextureShader(uint vertexID [[ vertex_id ]],
             constant TextureVertex *vertexArray [[ buffer(0) ]],
             constant vector_uint2 *viewportSizePointer  [[ buffer(1) ]]) {
    
    TextureRasterizerData out;
    float2 pixelSpacePosition = vertexArray[vertexID].position.xy;
    float2 viewportSize = float2(*viewportSizePointer);
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.clipSpacePosition.z = 0.0;
    out.clipSpacePosition.w = 1.0;
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    return out;

}

fragment float4
samplingShader(TextureRasterizerData in [[stage_in]],
               texture2d<half> colorTexture [[ texture(0) ]]) {
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    const half4 sample = colorTexture.sample(textureSampler, in.textureCoordinate);
    return float4(sample);

}
