//
//  Compute.metal
//  MetalDemo
//
//  Created by JGL on 2018/8/18.
//  Copyright © 2018 JGL. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;
#include "MetalDemo/Foundation/TextureVertex.h"

struct TextureRasterizerData {
    float4 clipSpacePosition [[position]];
    float2 textureCoordinate;
};

vertex TextureRasterizerData
grayVertexShader(uint vertexID [[ vertex_id ]],
             constant TextureVertex *vertexArray [[ buffer(0) ]],
             constant vector_uint2 *viewportSizePointer  [[ buffer(1) ]]) {
    TextureRasterizerData data;
    TextureVertex point = vertexArray[vertexID];
    float2 viewportSize = float2(*viewportSizePointer);
    data.clipSpacePosition.xy = point.position.xy / (viewportSize/2);
    data.clipSpacePosition.w = 1.0;
    data.clipSpacePosition.z = 0;
    data.textureCoordinate = point.textureCoordinate;
    return data;
}

//fragment float4
//samplingShader(TextureRasterizerData in [[stage_in]],
//               texture2d<half> colorTexture [[ texture(0) ]]) {
//    constexpr sampler textureSampler (mag_filter::linear,
//                                      min_filter::linear);
//    const half4 sample = colorTexture.sample(textureSampler, in.textureCoordinate);
//    return float4(sample);
//}

fragment float4
graySampleShader(TextureRasterizerData in [[stage_in]],
                 texture2d<half> texture [[texture(0)]]) {
    constexpr sampler textureSampler (mag_filter:: linear, min_filter:: linear);
    const half4 sample = texture.sample(textureSampler, in.textureCoordinate);
    return float4(sample);
}

// Rec. 709 luma values for grayscale image conversion
constant half3 kRec709Luma = half3(0.2126, 0.7152, 0.0722);

kernel void
grayscale(texture2d<half, access::read>  in  [[texture(0)]],
          texture2d<half, access::write> out [[texture(1)]],
          uint2 gid [[thread_position_in_grid]])
{

//     Check if the pixel is within the bounds of the output texture
    if((gid.x >= out.get_width()) || (gid.y >= out.get_height()))
    {
        return;
    }
    half4 inColor = in.read(gid);
    half gray = dot(inColor.rgb, kRec709Luma);
    out.write(half4(gray, gray, gray, 1.0), gid);

}
