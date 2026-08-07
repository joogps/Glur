//
//  CompatibilityView.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//

import SwiftUI

internal struct CompatibilityModifier: ViewModifier {
    public var radius: CGFloat
    public var mask: GlurMask
    public var drawingGroup: Bool

    @Environment(\.layoutDirection) var layoutDirection

    @ViewBuilder
    func body(content: Content) -> some View {
        if radius.isZero {
            content
        } else {
            content
                .overlay {
                    Group {
                        if drawingGroup {
                            content
                                .drawingGroup()
                        } else {
                            content
                        }
                    }
                    .allowsHitTesting(false)
                    .blur(radius: radius)
                    .scaleEffect(1+(radius*0.02))
                    .mask(mask.view(layoutDirection: layoutDirection))
                }
        }
    }
}
