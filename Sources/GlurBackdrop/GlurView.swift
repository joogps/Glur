//
//  GlurView.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 04/08/25.
//

import SwiftUI
import Glur

/// A view that applies a gradient blur to the content *behind* it.
///
/// Unlike the `glur` modifier, which blurs the view it is applied to, `GlurView` is a
/// transparent overlay that blurs whatever is rendered underneath it. That makes it
/// usable over content the SwiftUI shader API can't reach, such as `ScrollView` or other
/// platform-backed views.
///
/// ```swift
/// content
///     .overlay(alignment: .top) {
///         GlurView(radius: 8.0, direction: .up)
///             .frame(height: 100)
///     }
/// ```
///
/// The effect is shaped by the same ``Glur/GlurMask`` the modifier uses, so linear,
/// radial and custom masks all work here too.
///
/// > Warning: This reaches a **private API** on every platform it supports, since nothing
/// public applies a varying blur to a backdrop. That's why it lives in the separate
/// `GlurBackdrop` module — importing `Glur` alone keeps your binary free of it. Review
/// your own risk tolerance before shipping it.
///
/// > Note: Not available on watchOS, where the view renders as empty space.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *)
public struct GlurView: View {
    /// The radius of the blur effect where the mask is fully applied.
    public var radius: CGFloat

    /// Where the effect is applied across the view, and how strongly.
    public var mask: GlurMask

    @Environment(\.layoutDirection) private var layoutDirection

    /// Creates a view that progressively blurs its backdrop.
    ///
    /// - Parameters:
    ///   - radius: The total radius of the blur effect when fully applied.
    ///   - mask: Where the effect is applied across the view, and how strongly.
    public init(radius: CGFloat = 8.0, mask: GlurMask) {
        assert(radius >= 0.0, "Radius must be greater than or equal to 0")

        self.radius = radius
        self.mask = mask
    }

    /// Creates a view that progressively blurs its backdrop, along an axis.
    ///
    /// - Parameters:
    ///   - radius: The total radius of the blur effect when fully applied.
    ///   - offset: The distance from the view's edge to where the effect begins, relative to the view's size.
    ///   - interpolation: The distance from the offset to where the effect is fully applied, relative to the view's size.
    ///   - direction: The direction in which the effect is applied.
    public init(radius: CGFloat = 8.0,
                offset: CGFloat = 0.0,
                interpolation: CGFloat = 1.0,
                direction: BlurDirection = .down) {
        assert(offset >= 0.0 && offset <= 1.0, "Offset must be between 0 and 1")
        assert(interpolation >= 0.0 && interpolation <= 1.0, "Interpolation must be between 0 and 1")

        self.init(radius: radius,
                  mask: .linear(direction: direction,
                                offset: offset,
                                interpolation: interpolation))
    }

    public var body: some View {
        #if canImport(UIKit) && !os(watchOS)
        Representable(radius: radius, mask: mask, layoutDirection: layoutDirection)
            .allowsHitTesting(false)
        #elseif canImport(AppKit)
        Representable(radius: radius, mask: mask, layoutDirection: layoutDirection)
            .allowsHitTesting(false)
        #else
        Color.clear
        #endif
    }
}

#if canImport(UIKit) && !os(watchOS)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *)
extension GlurView {
    fileprivate struct Representable: UIViewRepresentable {
        var radius: CGFloat
        var mask: GlurMask
        var layoutDirection: LayoutDirection

        func makeUIView(context: Context) -> GlurBackdropUIView {
            GlurBackdropUIView(radius: radius, mask: mask, layoutDirection: layoutDirection)
        }

        func updateUIView(_ uiView: GlurBackdropUIView, context: Context) {
            uiView.update(radius: radius, mask: mask, layoutDirection: layoutDirection)
        }
    }
}
#elseif canImport(AppKit)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *)
extension GlurView {
    fileprivate struct Representable: NSViewRepresentable {
        var radius: CGFloat
        var mask: GlurMask
        var layoutDirection: LayoutDirection

        func makeNSView(context: Context) -> GlurBackdropNSView {
            GlurBackdropNSView(radius: radius, mask: mask, layoutDirection: layoutDirection)
        }

        func updateNSView(_ nsView: GlurBackdropNSView, context: Context) {
            nsView.update(radius: radius, mask: mask, layoutDirection: layoutDirection)
        }
    }
}
#endif
