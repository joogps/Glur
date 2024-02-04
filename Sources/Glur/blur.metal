//
//  blur.metal
//  WWDCApp
//
//  Created by João Gabriel Pozzobon dos Santos on 06/06/23.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

float mapRadius(float2 position, float2 size, float offset, float interpolation, float radius, float direction) {
    float mapped;
    
    if (direction == 0) {
        mapped = max((position.y/size.y*3-offset)/interpolation, 0.0);
    } else if (direction == 1) {
        mapped = max(1-(position.y/size.y*3-offset)/interpolation, 0.0);
    } else if (direction == 2) {
        mapped = max((position.x/size.x*3-offset)/interpolation, 0.0);
    } else if (direction == 3) {
        mapped = max(1-(position.x/size.x*3-offset)/interpolation, 0.0);
    }
    
    return min(mapped*radius, radius);
}

void calculateGaussianWeights(float radius, int kernelSize, thread half weights[]) {
    half sum = 0.0;
    
    for (int i = 0; i < kernelSize; ++i) {
        float x = i-(kernelSize-1)/2;
        weights[i] = exp(-(x*x)/(2.0*radius*radius));
        sum+= weights[i];
    }
    
    for (int i = 0; i < kernelSize; ++i) {
        weights[i]/= sum;
    }
}

[[ stitchable ]] half4 blurX(float2 position, SwiftUI::Layer layer, float offset, float interpolation, float radius, float direction) {
    float r = mapRadius(position, float2(layer.tex.get_width(), layer.tex.get_height()), offset, interpolation, radius, direction);
    
    if (r == 0) {
        return layer.sample(position);
    }
    
    constexpr int kernelSize = 64;
    half weights[kernelSize];
    
    calculateGaussianWeights(r, kernelSize, weights);
    
    half4 result = half4(0.0);
    for (int i = 0; i < kernelSize; ++i) {
        float offset = i-(kernelSize-1)/2;
        result+= layer.sample(position+float2(offset, 0.0))*weights[i];
    }
    
    return result;
}

[[ stitchable ]] half4 blurY(float2 position, SwiftUI::Layer layer, float offset, float interpolation, float radius, float direction) {
    float r = mapRadius(position, float2(layer.tex.get_width(), layer.tex.get_height()), offset, interpolation, radius, direction);
    
    if (r == 0) {
        return layer.sample(position);
    }
    
    constexpr int kernelSize = 64;
    half weights[kernelSize];
    
    calculateGaussianWeights(r, kernelSize, weights);
    
    half4 result = half4(0.0);
    for (int i = 0; i < kernelSize; ++i) {
        float offset = i-(kernelSize-1)/2;
        result+= layer.sample(position+float2(0.0, offset))*weights[i];
    }
    
    return result;
}
