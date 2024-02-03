import SwiftUI

let library = ShaderLibrary.bundle(.module)

extension View {
    public func blur(offset: CGFloat = 0.5, interpolation: CGFloat = 0.3, radius: CGFloat = 16.0, direction: BlurDirection = .down) -> some View {
        self
            .layerEffect(library.blurY(.float(offset), .float(interpolation), .float(radius), .float(Float(direction.rawValue))), maxSampleOffset: .zero)
            .layerEffect(library.blurX(.float(offset), .float(interpolation), .float(radius), .float(Float(direction.rawValue))), maxSampleOffset: .zero)
    }
}

public enum BlurDirection: Int {
    case down = 0
    case up = 1
    case right = 2
    case left = 3
}
