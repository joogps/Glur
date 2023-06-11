import SwiftUI

let library = ShaderLibrary.bundle(.module)

extension View {
    public func blur(offset: CGFloat = 0.5, interpolation: CGFloat = 0.1) -> some View {
        self
            .layerEffect(library.blurX(.float(offset), .float(interpolation)), maxSampleOffset: .zero)
            .layerEffect(library.blurY(.float(offset), .float(interpolation)), maxSampleOffset: .zero)
    }
}
