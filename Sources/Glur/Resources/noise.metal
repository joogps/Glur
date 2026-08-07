//
//  noise.metal
//
//
//  Created by João Gabriel Pozzobon dos Santos on 24/04/24.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

constexpr sampler maskSampler(filter::linear, address::clamp_to_edge);

float overlay(float base, float blend) {
    return (base <= 0.5) ? (2.0*base*blend) : (1.0-2.0*(1.0-base)*(1.0-blend));
}

float rand(float2 st) {
    return fract(sin(dot(st.xy,
                         float2(12.9898,78.233)))*
                 43758.5453123);
}

[[ stitchable ]] half4 noise(float2 position,
                             SwiftUI::Layer layer,
                             texture2d<half> mask,
                             float strength,
                             float2 size) {
    // The noise follows the same mask as the blur.
    float s = float(mask.sample(maskSampler, position/size).a)*strength;

    float2 pos = position*10;
    float2 floored = floor(pos);

    float white = rand(floored)*0.5+0.5;
    half4 color = layer.sample(position);

    float r = overlay(color.r, white);
    float g = overlay(color.g, white);
    float b = overlay(color.b, white);
    
    half4 newColor = half4(r, g, b, color.a);
    return mix(color, newColor, s);
}
