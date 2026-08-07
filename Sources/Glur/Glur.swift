//
//  Glur.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//

import SwiftUI

extension View {
    /// A modifier that applies a gradient blur effect to the view.
    ///
    /// - Parameters:
    ///   - radius: The total radius of the blur effect when fully applied.
    ///   - offset: The distance from the view's edge to where the effect begins, relative to the view's size.
    ///   - interpolation: The distance from the offset to where the effect is fully applied, relative to the view's size.
    ///   - direction: The direction in which the effect is applied.
    ///   - noise: The amount of noise that should be applied to the view.
    ///   - drawingGroup: Whether or not to pre-render the modified view with `drawingGroup()`.
    public func glur(radius: CGFloat = 8.0,
                     offset: CGFloat = 0.3,
                     interpolation: CGFloat = 0.4,
                     direction: BlurDirection = .down,
                     noise: CGFloat = 0.1,
                     drawingGroup: Bool = true) -> some View {
        assert(offset >= 0.0 && offset <= 1.0, "Offset must be between 0 and 1")
        assert(interpolation >= 0.0 && interpolation <= 1.0, "Interpolation must be between 0 and 1")

        return glur(radius: radius,
                    mask: .linear(direction: direction,
                                  offset: offset,
                                  interpolation: interpolation),
                    noise: noise,
                    drawingGroup: drawingGroup)
    }

    /// A modifier that applies a blur effect to the view, shaped by a mask.
    ///
    /// - Parameters:
    ///   - radius: The total radius of the blur effect where the mask is fully applied.
    ///   - mask: Where the effect is applied across the view, and how strongly.
    ///   - noise: The amount of noise that should be applied to the view.
    ///   - drawingGroup: Whether or not to pre-render the modified view with `drawingGroup()`.
    public func glur(radius: CGFloat = 8.0,
                     mask: GlurMask,
                     noise: CGFloat = 0.1,
                     drawingGroup: Bool = true) -> some View {
        assert(radius >= 0.0, "Radius must be greater than or equal to 0")
        assert(noise >= 0.0, "Noise must be greater than or equal to 0")

        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, visionOS 1.0, *) {
            return modifier(GlurModifier(radius: radius,
                                         mask: mask,
                                         noise: noise,
                                         drawingGroup: drawingGroup))
        } else {
            return modifier(CompatibilityModifier(radius: radius,
                                                  mask: mask,
                                                  drawingGroup: drawingGroup))
        }
    }
}
