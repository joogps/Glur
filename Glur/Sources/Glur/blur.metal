//
//  blur.metal
//  WWDCApp
//
//  Created by João Gabriel Pozzobon dos Santos on 06/06/23.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

#define RADIUS (15.0)

[[ stitchable ]] half4 blurX(float2 position, SwiftUI::Layer layer, float offset, float interpolation) {
    float mapped = max((position.y/(float)layer.tex.get_height()*3-offset)/interpolation, 0.0);
    float radius = min(mapped*RADIUS, RADIUS);
    
    half4 source = half4(0);
    
    float width = (float)layer.tex.get_width()/3;
    
    int minX = max(position.x-radius, 0.0);
    int maxX = min(position.x+radius, width);
    
    for(int x = minX; x <= maxX; x++) {
        source += layer.sample(float2(x, position.y));
    }
    
    half size = maxX-minX+1;
    source = source/size;
    return source;
}

[[ stitchable ]] half4 blurY(float2 position, SwiftUI::Layer layer, float offset, float interpolation) {
    float mapped = max((position.y/(float)layer.tex.get_height()*3-offset)/interpolation, 0.0);
    float radius = min(mapped*RADIUS, RADIUS);
    
    half4 source = half4(0);
    
    float height = (float)layer.tex.get_height()/3;
    
    int minY = max(position.y-radius, 0.0);
    int maxY = min(position.y+radius, height);
    
    for(int y = minY; y <= maxY; y++) {
        source += layer.sample(float2(position.x, y));
    }
    
    half size = maxY-minY+1;
    source = source/size;
    return source;
}


float normpdf(float x, float sigma) {
    return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}
