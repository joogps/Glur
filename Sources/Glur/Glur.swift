import SwiftUI

let library = ShaderLibrary.bundle(.module)

extension View {
    /// A modifier that applies a gradient blur effect to the view.
    public func glur(offset: CGFloat = 0.3,
                     interpolation: CGFloat = 0.4,
                     radius: CGFloat = 8.0,
                     direction: BlurDirection = .down) -> some View {
        modifier(GlurModifier(offset: offset,
                              interpolation: interpolation,
                              radius: radius,
                              direction: direction))
    }
}

private struct GlurModifier: ViewModifier {
    public var offset: CGFloat
    public var interpolation: CGFloat
    public var radius: CGFloat
    public var direction: BlurDirection
    
    @Environment(\.displayScale) var displayScale
    
    var blurX: Shader {
        var shader = library.blurX(.float(offset),
                      .float(interpolation),
                      .float(radius),
                      .float(Float(direction.rawValue)),
                      .float(displayScale))
        shader.dithersColor = true
        return shader
    }
    
    var blurY: Shader {
        var shader = library.blurY(.float(offset),
                                   .float(interpolation),
                                   .float(radius),
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

public enum BlurDirection: Int {
    case down = 0
    case up = 1
    case right = 2
    case left = 3
}
