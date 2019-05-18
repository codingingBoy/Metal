//
//  FilterShader.metal
//  MetalDemo
//
//  Created by JGL on 2018/11/23.
//  Copyright © 2018 JGL. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "MetalDemo/Foundation/TextureVertex.h"

struct TextureRasterizerData {
    float4 clipSpacePosition [[position]];
    float2 textureCoordinate;
};

vertex TextureRasterizerData filter_vertex(uint index [[vertex_id]],
                                           constant TextureVertex * vertexs [[buffer(0)]],
                                           constant float2 *size [[buffer(1)]]) {
    TextureRasterizerData out;
    TextureVertex in = vertexs[index];

    float2 viewportSize = *size;
    out.clipSpacePosition.xy = in.position.xy / (viewportSize/2);
    out.clipSpacePosition.w = 1.0;
    out.clipSpacePosition.z = 0;
    out.textureCoordinate = in.textureCoordinate;
    return out;
}

fragment float4 filter_fragment(TextureRasterizerData in [[stage_in]],
                                texture2d<half, access::sample> texture [[texture(0)]]) {
    constexpr sampler textureSampler (mag_filter:: linear, min_filter:: linear);
    const half4 rgba = texture.sample(textureSampler, in.textureCoordinate);
    return float4(rgba.r, rgba.g, rgba.b, 0.5);
}

//kernel void filter_compute(texture2d<half, access::read> inputTexture [[texture(0)]],
//                           texture2d<half, access::sample> filterTexture [[texture(1)]],
//                           texture2d<half, access::write> outputTexture [[texture(2)]],
//                           uint2 gid [[thread_position_in_grid]]) {
//    constexpr sampler samp (mag_filter:: linear, min_filter:: linear);
//
//    half4 inColor = inputTexture.read(gid);

//#if 0
//    half blue = inColor.b;
//    half red = inColor.r;
//    half green = inColor.g;
//
//    half n = floor(blue*63/8);
//    half m = floor(blue*63 - n * 8);
//
//    half x = (m + red) / 8;
//    half y = (n + green) / 8;
//
//    half4 outColor = filterTexture.sample(samp, float2(x, y));
//    outputTexture.write(outColor, gid);
//
//#endif
//    half3x3 RGBtoYIQ = half3x3(half3(0.299, 0.587, 0.114),
//            half3(0.596, -0.274, -0.322),
//            half3(0.212, -0.523, 0.311));
////    half3(0.299 * color.r + 0.587 * color.g + 0.144 * color.b,
////          0.596 * color.r - 0.247 * color.g - 0.322 * color.b,
////          0.212 * color.r - 0.523 * color.g + 0.311 * color.b);
//
//
//    half3 outColor = inColor.rgb * RGBtoYIQ;
//    outputTexture.write(half4(outColor, 1), gid);
//        outputTexture.write(inColor, gid);
//}
