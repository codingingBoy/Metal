//
//  TextureVertex.h
//  MetalDemo
//
//  Created by JGL on 2018/7/29.
//  Copyright © 2018 JGL. All rights reserved.
//

#include <simd/simd.h>

#ifndef TextureVertex_h
#define TextureVertex_h

struct TextureVertex {
    vector_float2 position;
    vector_float2 textureCoordinate;
};


#endif /* TextureVertex_h */
