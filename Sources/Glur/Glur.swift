import SwiftUI

let library = ShaderLibrary.bundle(.module)

extension View {
    public func glur(offset: CGFloat = 0.3, interpolation: CGFloat = 0.1, radius: CGFloat = 6.0, direction: BlurDirection = .down) -> some View {
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
