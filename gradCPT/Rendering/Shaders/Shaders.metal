//
//  Shaders.metal
//  gradCPT
//
//  Created by Shawn Schwartz on 1/17/25.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position [[attribute(0)]];
    float2 texCoords [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoords;
    float2 normalizedPos;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant float4* vertices [[buffer(0)]],
                              constant float2& scale [[buffer(1)]]) {
    VertexOut out;
    float2 position = float2(vertices[vertexID].x, vertices[vertexID].y);
    out.texCoords = float2(vertices[vertexID].z, vertices[vertexID].w);

    out.normalizedPos = position;  // Store normalized position for circle clipping

    // Scale the position with aspect ratio correction
    position *= scale;
    out.position = float4(position, 0, 1);

    return out;
}

// MARK: - Core Metal Shaders to Handle City and Mountain Scene Images
fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> texture1 [[texture(0)]],
                               texture2d<float> texture2 [[texture(1)]],
                               constant float& blend [[buffer(0)]]) {
    // Calculate distance from center for circle clipping
    // Note: using normalizedPos ensures a perfect circle
    float dist = length(in.normalizedPos);

    // Return white if outside the circle
    if (dist > 1.0) {
        return float4(1.0, 1.0, 1.0, 1.0);
    }

    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);

    float4 color1 = texture1.sample(textureSampler, in.texCoords);
    float4 color2 = texture2.sample(textureSampler, in.texCoords);

    // Adjusted grayscale conversion with increased brightness
    float3 grayWeights = float3(0.2989, 0.5870, 0.1140);  // Default grayscale weights
    float gray1 = dot(color1.rgb, grayWeights);
    float gray2 = dot(color2.rgb, grayWeights);

    // Brightness adjustments
    float brightnessAdjustment = 1.5;
    gray1 = min(gray1 * brightnessAdjustment, 1.0);
    gray2 = min(gray2 * brightnessAdjustment, 1.0);

    float baselineBrightness = 0.2;
    gray1 = min(gray1 + baselineBrightness, 1.0);
    gray2 = min(gray2 + baselineBrightness, 1.0);

    color1.rgb = float3(gray1);
    color2.rgb = float3(gray2);

    return mix(color1, color2, blend);
}
