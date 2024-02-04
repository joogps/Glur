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
    float mapped = 0.0;
    
    if (direction == 0) {
        mapped = max((position.y/size.y*3-offset)/interpolation, 0.0);
    } else if (direction == 1) {
        mapped = 1-max((position.y/size.y*3-offset)/interpolation, 0.0);
    } else if (direction == 2) {
        mapped = max((position.x/size.x*3-offset)/interpolation, 0.0);
    } else if (direction == 3) {
        mapped = 1-max((position.x/size.x*3-offset)/interpolation, 0.0);
    }
    
    return min(round(mapped*radius), radius);
}

float oneDimensionalGaussianWeight(float x, float radius) {
    return exp(-x*x/(2.0f*radius*radius))/(sqrt(2.0f*3.14159265359f)*radius);
}

[[ stitchable ]] half4 blurX(float2 position, SwiftUI::Layer layer, float offset, float interpolation, float radius, float direction) {
    float r = mapRadius(position, float2(layer.tex.get_width(), layer.tex.get_height()), offset, interpolation, radius, direction);
    
    if (r == 0) {
        return layer.sample(position);
    }
    
    half4 source = half4(0);
    
    float width = (float)layer.tex.get_width()/3;
    
    int minX = max(position.x-r, 0.0);
    int maxX = min(position.x+r, width);
    
    float total = 0;
    for(int x = minX; x <= maxX; x++) {
        float w = oneDimensionalGaussianWeight(x-position.x, r);
        source += layer.sample(float2(x, position.y))*w;
        total += w;
    }
    return source/total;
}

[[ stitchable ]] half4 blurY(float2 position, SwiftUI::Layer layer, float offset, float interpolation, float radius, float direction) {
    float r = mapRadius(position, float2(layer.tex.get_width(), layer.tex.get_height()), offset, interpolation, radius, direction);
    
    if (r == 0) {
        return layer.sample(position);
    }
    
    half4 source = half4(0);
    
    float height = (float)layer.tex.get_height()/3;
    
    int minY = max(position.y-r, 0.0);
    int maxY = min(position.y+r, height);
    
    float total = 0;
    for(int y = minY; y <= maxY; y++) {
        float w = oneDimensionalGaussianWeight(y-position.y, r);
        source += layer.sample(float2(position.x, y))*w;
        total += w;
    }
    return source/total;
}
