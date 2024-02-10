//
//  GlurModifier.swift
//  
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//

import SwiftUI

@available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
internal struct GlurModifier: ViewModifier {
    public var radius: CGFloat
    public var offset: CGFloat
    public var interpolation: CGFloat
    public var direction: BlurDirection
    
    @Environment(\.displayScale) var displayScale
    
    let library = ShaderLibrary.bundle(.module)
    
    var blurX: Shader {
        var shader = library.blurX(.float(radius),
                                   .float(offset),
                                   .float(interpolation),
                                   .float(Float(direction.rawValue)),
                                   .float(displayScale))
        shader.dithersColor = true
        return shader
    }
    
    var blurY: Shader {
        var shader = library.blurY(.float(radius),
                                   .float(offset),
                                   .float(interpolation),
                                   .float(Float(direction.rawValue)),
                                   .float(displayScale))
        shader.dithersColor = true
        return shader
    }
    
    public func body(content: Content) -> some View {
        content
            .drawingGroup()
            .layerEffect(blurX, maxSampleOffset: .zero)
            .layerEffect(blurY, maxSampleOffset: .zero)
    }
}
