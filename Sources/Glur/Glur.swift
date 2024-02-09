//
//  Glur.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//

import SwiftUI

extension View {
    /// A modifier that applies a gradient blur effect to the view.
    @ViewBuilder
    public func glur(offset: CGFloat = 0.3,
                     interpolation: CGFloat = 0.4,
                     radius: CGFloat = 8.0,
                     direction: BlurDirection = .down) -> some View {
        if #available(iOS 17.0, macOS 14.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *) {
            modifier(GlurModifier(offset: offset,
                                  interpolation: interpolation,
                                  radius: radius,
                                  direction: direction))
        } else {
            modifier(CompatibilityModifier(offset: offset,
                                  interpolation: interpolation,
                                  radius: radius,
                                  direction: direction))
        }
    }
}
