//
//  GlurBackdropNSView.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 04/08/25.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit
import QuartzCore
import SwiftUI
import Glur

/// A view that blurs what's rendered behind it, shaped by a ``Glur/GlurMask``.
///
/// Two approaches don't work here, both worth knowing about. `CALayer.backgroundFilters`
/// is genuinely supported on macOS, but only for an AppKit layer hierarchy: SwiftUI draws
/// its content into its own hosting layer rather than into sibling layers beneath this
/// one, so nothing is composited behind the view and the filter runs against nothing.
/// `NSVisualEffectView`, the iOS route's counterpart, has no in-process backdrop layer to
/// borrow — its own layer has no sublayers, because the blur happens out of process.
///
/// What's left is to build the backdrop layer directly and host it.
///
/// > Warning: This reaches ``BackdropBlurFilter``, which is private API. See ``GlurView``.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *)
open class GlurBackdropNSView: NSView {
    private let filter = BackdropBlurFilter()
    private var backdrop: CALayer?

    private var radius: CGFloat
    private var glurMask: GlurMask
    private var layoutDirection: LayoutDirection

    public init(radius: CGFloat, mask: GlurMask, layoutDirection: LayoutDirection = .leftToRight) {
        self.radius = radius
        self.glurMask = mask
        self.layoutDirection = layoutDirection

        super.init(frame: .zero)

        wantsLayer = true
        layer?.masksToBounds = true

        guard let filter, let backdrop = BackdropBlurFilter.makeBackdropLayer() else {
            NSLog("[Glur] Error: the backdrop blur filter is unavailable")
            return
        }

        backdrop.filters = [filter.object]
        layer?.addSublayer(backdrop)
        self.backdrop = backdrop

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

    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        guard let window else { return }
        backdrop?.setBackdropScale(window.backingScaleFactor)
    }

    open override func layout() {
        super.layout()

        // The layer is positioned by hand, so it has to follow the view's bounds.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backdrop?.frame = bounds
        CATransaction.commit()
    }

    private func applyParameters() {
        filter?.apply(radius: radius, mask: glurMask.cgImage(layoutDirection: layoutDirection))
    }
}

#endif
