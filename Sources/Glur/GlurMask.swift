//
//  GlurMask.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 04/08/25.
//

import SwiftUI
import CoreGraphics

/// Describes where the effect is applied across a view, and how strongly.
///
/// A mask is a ramp: an intensity of `0` leaves the view untouched, while an intensity of
/// `1` applies the full radius. The default, ``linear(direction:offset:interpolation:)``,
/// is the gradient the `glur` modifier has always used, but any ramp can be supplied.
///
/// ```swift
/// // The default effect, spelled out
/// .glur(radius: 8.0, mask: .linear(direction: .down, offset: 0.3, interpolation: 0.4))
///
/// // Sharp in the middle, blurred towards the corners
/// .glur(radius: 8.0, mask: .radial(offset: 0.2, interpolation: 0.5))
///
/// // Anything SwiftUI can draw
/// .glur(radius: 8.0, mask: .view(AngularGradient(colors: [.black, .clear], center: .center)))
/// ```
///
/// Every mask is a SwiftUI gradient underneath, drawn into a square and stretched to fit
/// the view. Only **opacity** is read, so colors are ignored: `.black` to `.clear` reads
/// the same as `.white` to `.clear`.
public struct GlurMask {
    /// A point along the mask's ramp.
    public struct Stop: Hashable {
        /// How strongly the effect is applied, from `0` to `1`.
        public var intensity: CGFloat

        /// Where the stop sits along the ramp, from `0` to `1`.
        public var location: CGFloat

        public init(intensity: CGFloat, location: CGFloat) {
            self.intensity = intensity
            self.location = location
        }
    }

    internal enum Shape: Hashable {
        /// Resolved against the layout direction when the mask is drawn.
        case directional(BlurDirection)
        case linear(startPoint: UnitPoint, endPoint: UnitPoint)
        case radial(center: UnitPoint, startRadius: CGFloat, endRadius: CGFloat)
    }

    internal struct Ramp: Hashable {
        var shape: Shape
        var stops: [Stop]
    }

    internal enum Source {
        case ramp(Ramp)
        case content(AnyView)
        case image(CGImage)
    }

    internal var source: Source

    // MARK: - Gradients

    /// A gradient that begins at `offset` from the view's edge and reaches the full
    /// radius `interpolation` later, both relative to the view's size.
    ///
    /// - Parameters:
    ///   - direction: The direction in which the effect is applied.
    ///   - offset: The distance from the view's edge to where the effect begins, relative to the view's size.
    ///   - interpolation: The distance from the offset to where the effect is fully applied, relative to the view's size.
    public static func linear(direction: BlurDirection = .down,
                              offset: CGFloat = 0.3,
                              interpolation: CGFloat = 0.4) -> GlurMask {
        GlurMask(source: .ramp(Ramp(shape: .directional(direction),
                                    stops: ramp(offset: offset, interpolation: interpolation))))
    }

    /// A gradient running between two points in the view's unit space.
    public static func linear(stops: [Stop],
                              startPoint: UnitPoint = .top,
                              endPoint: UnitPoint = .bottom) -> GlurMask {
        GlurMask(source: .ramp(Ramp(shape: .linear(startPoint: startPoint, endPoint: endPoint),
                                    stops: stops)))
    }

    /// A gradient radiating from a point, leaving the center sharp and blurring outwards.
    ///
    /// - Parameters:
    ///   - center: The point the effect radiates from, in the view's unit space.
    ///   - offset: The distance from the center to where the effect begins, relative to the spread.
    ///   - interpolation: The distance from the offset to where the effect is fully applied, relative to the spread.
    ///   - spread: How far the gradient reaches, as a multiple of the view's longest side.
    ///   A value of `1.0` reaches the far edge; larger values push the ramp outwards, so
    ///   the falloff is wider and gentler and the corners never reach the full radius.
    public static func radial(center: UnitPoint = .center,
                              offset: CGFloat = 0.3,
                              interpolation: CGFloat = 0.4,
                              spread: CGFloat = 1.0) -> GlurMask {
        GlurMask(source: .ramp(Ramp(shape: .radial(center: center,
                                                   startRadius: 0.0,
                                                   endRadius: max(spread, .ulpOfOne)),
                                    stops: ramp(offset: offset, interpolation: interpolation))))
    }

    /// A gradient radiating from a point, with explicit stops and radii.
    ///
    /// The radii are relative to the view's longest side.
    public static func radial(stops: [Stop],
                              center: UnitPoint = .center,
                              startRadius: CGFloat = 0.0,
                              endRadius: CGFloat = 1.0) -> GlurMask {
        GlurMask(source: .ramp(Ramp(shape: .radial(center: center,
                                                   startRadius: startRadius,
                                                   endRadius: endRadius),
                                    stops: stops)))
    }

    // MARK: - Custom

    /// A mask drawn by a SwiftUI view, most usefully a gradient.
    ///
    /// Anything SwiftUI can draw can shape the effect, which covers the gradients the
    /// built-in masks don't reach — angular, elliptical, mesh — along with shapes, text
    /// and images.
    ///
    /// ```swift
    /// .glur(radius: 8.0, mask: .view(AngularGradient(colors: [.black, .clear],
    ///                                                center: .center)))
    /// ```
    ///
    /// > Note: The built-in gradients are cached by their parameters, which a view can't
    /// be, so this one is redrawn whenever the effect updates. Prefer a built-in mask
    /// where one will do.
    public static func view<Content: View>(_ content: Content) -> GlurMask {
        GlurMask(source: .content(AnyView(content)))
    }

    /// An arbitrary bitmap, stretched to fit the view.
    ///
    /// The image's alpha drives the effect, so a fully opaque image applies the full
    /// radius everywhere.
    public static func image(_ image: CGImage) -> GlurMask {
        GlurMask(source: .image(image))
    }

    /// The two stops behind the offset/interpolation pair.
    ///
    /// When the ramp would run past the far end it is truncated rather than squeezed, so
    /// the part that is visible keeps the slope that was asked for.
    private static func ramp(offset: CGFloat, interpolation: CGFloat) -> [Stop] {
        let start = min(max(offset, 0.0), 1.0)
        let end = start + max(interpolation, 0.0)

        guard end > 1.0 else {
            // Kept apart, so a zero interpolation is a hard edge rather than undefined.
            return [Stop(intensity: 0.0, location: start),
                    Stop(intensity: 1.0, location: max(end, start + .ulpOfOne))]
        }

        let truncated = interpolation > 0.0 ? (1.0 - start)/interpolation : 1.0
        return [Stop(intensity: 0.0, location: start),
                Stop(intensity: min(truncated, 1.0), location: 1.0)]
    }
}

// MARK: - Drawing

extension GlurMask {
    /// The mask as a view. Every mask is one of these; the bitmap the shader samples is
    /// this view rendered.
    @ViewBuilder
    public func view(layoutDirection: LayoutDirection = .leftToRight) -> some View {
        switch source {
        case .content(let content):
            content
        case .image(let image):
            Image(decorative: image, scale: 1.0)
                .resizable()
        case .ramp(let ramp):
            let resolved = ramp.resolved(with: layoutDirection)
            let stops = resolved.stops.map {
                Gradient.Stop(color: .white.opacity($0.intensity), location: $0.location)
            }

            switch resolved.shape {
            case .radial(let center, let startRadius, let endRadius):
                GeometryReader { proxy in
                    let side = max(proxy.size.width, proxy.size.height)
                    RadialGradient(stops: stops,
                                   center: center,
                                   startRadius: startRadius*side,
                                   endRadius: endRadius*side)
                }
            case .linear(let startPoint, let endPoint):
                LinearGradient(stops: stops, startPoint: startPoint, endPoint: endPoint)
            case .directional:
                EmptyView()
            }
        }
    }
}

// MARK: - Rendering

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, visionOS 1.0, *)
extension GlurMask {
    /// Gradients are smooth and sampled with linear filtering, so this is plenty.
    private static let resolution: CGFloat = 256.0

    /// The mask as a bitmap, stretched to fit the view it's applied to.
    ///
    /// Built-in gradients are cached by their parameters. A ``view(_:)`` mask can't be,
    /// so it is drawn on every call.
    @MainActor
    public func cgImage(layoutDirection: LayoutDirection = .leftToRight) -> CGImage? {
        if case .image(let image) = source { return image }

        if case .ramp(let ramp) = source {
            return Self.cache.image(for: ramp.resolved(with: layoutDirection)) {
                Self.render(self, layoutDirection: layoutDirection)
            }
        }

        return Self.render(self, layoutDirection: layoutDirection)
    }

    @MainActor
    internal func image(layoutDirection: LayoutDirection) -> Image? {
        guard let cgImage = cgImage(layoutDirection: layoutDirection) else { return nil }
        return Image(decorative: cgImage, scale: 1.0)
    }

    @MainActor
    private static func render(_ mask: GlurMask, layoutDirection: LayoutDirection) -> CGImage? {
        let content = mask.view(layoutDirection: layoutDirection)
            .frame(width: resolution, height: resolution)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 1.0

        guard let image = renderer.cgImage else { return nil }
        return flattened(image)
    }

    /// Redraws an image as white carrying its alpha, premultiplied, which is the shape
    /// every consumer of a mask expects: alpha and luminance holding the same value.
    private static func flattened(_ image: CGImage) -> CGImage? {
        let bounds = CGRect(x: 0, y: 0, width: image.width, height: image.height)
        let space = CGColorSpaceCreateDeviceRGB()

        guard let white = CGColor(colorSpace: space, components: [1.0, 1.0, 1.0, 1.0]),
              let context = CGContext(data: nil,
                                      width: image.width,
                                      height: image.height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: space,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }

        context.setFillColor(white)
        context.fill(bounds)
        context.setBlendMode(.destinationIn)
        context.draw(image, in: bounds)

        return context.makeImage()
    }

    private static let cache = Cache()

    /// Gradients depend only on their own parameters, never on the size of the view they
    /// end up on, so a rendered one can be held on to for as long as it's being used.
    private final class Cache {
        private var storage: [Ramp: CGImage] = [:]
        private let lock = NSLock()

        func image(for ramp: Ramp, render: () -> CGImage?) -> CGImage? {
            lock.lock()
            defer { lock.unlock() }

            if let image = storage[ramp] { return image }
            guard let image = render() else { return nil }

            // Should something drive a mask continuously, drop what's there rather than
            // growing forever.
            if storage.count >= 32 { storage.removeAll(keepingCapacity: true) }
            storage[ramp] = image

            return image
        }
    }
}

extension GlurMask.Ramp {
    /// Turns a direction into the pair of points it describes, which is the only part of
    /// a mask that depends on the environment.
    func resolved(with layoutDirection: LayoutDirection) -> GlurMask.Ramp {
        guard case .directional(let direction) = shape else { return self }

        let (startPoint, endPoint) = direction.evaluate(with: layoutDirection).unitPoints
        return GlurMask.Ramp(shape: .linear(startPoint: startPoint, endPoint: endPoint),
                             stops: stops)
    }
}
