//
//  blur.metal
//  WWDCApp
//
//  Created by João Gabriel Pozzobon dos Santos on 06/06/23.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// The widest half-kernel we're willing to run, which caps the effective radius.
//
// The effect is applied through layerEffect with a maxSampleOffset of zero, so the view's
// drawing bounds are never grown to accommodate it: a kernel wide enough to reach the
// edges leaves the blur cut off there rather than fading out. This is the reach the fixed
// 64-tap kernel used to have, kept so that existing views look the way they always did.
#define kMaxHalfWidth (31)

constexpr sampler maskSampler(filter::linear, address::clamp_to_edge);

/// The radius at this position, driven by the alpha of the corresponding pixel in the
/// mask. An alpha of 1 means the full radius, an alpha of 0 means no blur at all.
float mapRadius(float2 position,
                float2 size,
                texture2d<half> mask,
                float radius) {
    return float(mask.sample(maskSampler, position/size).a)*radius;
}

/// A single separable gaussian pass. The number of taps follows the radius, so small
/// radii don't pay for samples whose weights round to zero, and the weights are
/// normalized by the sum actually accumulated, so no energy is lost at large radii.
half4 gaussian(float2 position,
               SwiftUI::Layer layer,
               float2 size,
               float radius,
               bool horizontal) {
    int halfWidth = min(int(ceil(radius*3.0)), kMaxHalfWidth);

    half4 result = half4(0.0);
    float weightSum = 0.0;

    for (int i = -halfWidth; i <= halfWidth; ++i) {
        float weight = exp(-float(i*i)/(2.0*radius*radius));

        float2 samplePosition = position;
        if (horizontal) {
            samplePosition.x = clamp(position.x+float(i), 0.0, size.x-1.0);
        } else {
            samplePosition.y = clamp(position.y+float(i), 0.0, size.y-1.0);
        }

        result+= layer.sample(samplePosition)*half(weight);
        weightSum+= weight;
    }

    return result/half(weightSum);
}

[[ stitchable ]] half4 blurX(float2 position,
                             SwiftUI::Layer layer,
                             texture2d<half> mask,
                             float radius,
                             float2 size) {
    float r = mapRadius(position, size, mask, radius);

    if (r <= 0.0) {
        return layer.sample(position);
    }

    return gaussian(position, layer, size, r, true);
}

[[ stitchable ]] half4 blurY(float2 position,
                             SwiftUI::Layer layer,
                             texture2d<half> mask,
                             float radius,
                             float2 size) {
    float r = mapRadius(position, size, mask, radius);

    if (r <= 0.0) {
        return layer.sample(position);
    }

    return gaussian(position, layer, size, r, false);
}
