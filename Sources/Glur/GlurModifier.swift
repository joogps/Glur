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
    public var mask: GlurMask
    public var noise: CGFloat
    public var drawingGroup: Bool

    @State var size: CGSize = .zero

    @Environment(\.layoutDirection) var layoutDirection

    let library = ShaderLibrary.bundle(.module)

    var maskImage: Image? {
        mask.image(layoutDirection: layoutDirection)
    }

    /// Every pass takes the same shape: the mask, the amount, and the view's size.
    func shader(_ function: ShaderFunction, mask: Image, amount: CGFloat) -> Shader {
        var shader = function(.image(mask), .float(amount), .float2(size))
        shader.dithersColor = true
        return shader
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        if let mask = maskImage, !radius.isZero {
            Group {
                if drawingGroup {
                    content.drawingGroup()
                } else {
                    content
                }
            }
            .overlay {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: SizePreferenceKey.self, value: proxy.size)
                }
                .allowsHitTesting(false)
            }
            .onPreferenceChange(SizePreferenceKey.self) { size in
                self.size = size
            }
            .layerEffect(shader(library.blurX, mask: mask, amount: radius), maxSampleOffset: .zero)
            .layerEffect(shader(library.blurY, mask: mask, amount: radius), maxSampleOffset: .zero)
            .layerEffect(shader(library.noise, mask: mask, amount: noise), maxSampleOffset: .zero)
        } else {
            content
        }
    }
}

fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
