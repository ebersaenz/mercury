//
//  Shaders.metal
//  mercury
//
//  Created by Eber Saenz on 7/25/25.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position [[attribute(0)]];
    float3 color [[attribute(1)]];
    };

    struct VertexOut {
    float4 position [[position]];
    float3 color;
    };

    vertex VertexOut vertex_main(Vertex in [[stage_in]]) {
    VertexOut out;
    out.position = float4(in.position, 0.0, 1.0);
    out.color = in.color;
    return out;
    }

    fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return float4(in.color, 1.0);
}

