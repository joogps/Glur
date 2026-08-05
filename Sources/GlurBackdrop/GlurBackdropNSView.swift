//
//  GlurBackdropNSView.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 04/08/25.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI
import Glur

/// A layer-backed view that blurs what's behind it, shaped by a ``Glur/GlurMask``.
///
/// macOS supports `CALayer.backgroundFilters`, and Core Image ships a variable blur in
/// `CIMaskedVariableBlur`, so unlike the iOS implementation this one needs no private API.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *)
open class GlurBackdropNSView: NSView {
    private var radius: CGFloat
    private var glurMask: GlurMask
    private var layoutDirection: LayoutDirection

    public init(radius: CGFloat, mask: GlurMask, layoutDirection: LayoutDirection = .leftToRight) {
        self.radius = radius
        self.glurMask = mask
        self.layoutDirection = layoutDirection

        super.init(frame: .zero)

        // Has to be set before the layer is created, or the filters are silently dropped.
        layerUsesCoreImageFilters = true
        wantsLayer = true
        layer?.masksToBounds = true

        applyParameters()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var isOpaque: Bool { false }

    /// Updates the effect in place.
    public func update(radius: CGFloat, mask: GlurMask, layoutDirection: LayoutDirection) {
        self.radius = radius
        self.glurMask = mask
        self.layoutDirection = layoutDirection

        applyParameters()
    }

    open override func layout() {
        super.layout()

        // The mask is scaled to the layer, so it has to be rebuilt when the view resizes.
        applyParameters()
    }

    private func applyParameters() {
        guard let layer, bounds.width > 0.0, bounds.height > 0.0 else { return }

        guard let cgImage = glurMask.cgImage(layoutDirection: layoutDirection) else {
            layer.backgroundFilters = []
            return
        }

        // Core Image reads the mask's luminance rather than its alpha, which the
        // premultiplied white gradient carries just as well.
        let image = CIImage(cgImage: cgImage)
        let scale = CGAffineTransform(scaleX: bounds.width/image.extent.width,
                                      y: bounds.height/image.extent.height)

        let filter = CIFilter.maskedVariableBlur()
        filter.mask = image.transformed(by: scale)
        filter.radius = Float(radius)

        layer.backgroundFilters = [filter]
    }
}

#endif
