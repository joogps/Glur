//
//  GlurBackdropUIView.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 04/08/25.
//

#if canImport(UIKit) && !os(watchOS)

import UIKit
import SwiftUI
import Glur

/// A view that blurs what's rendered behind it, shaped by a ``Glur/GlurMask``.
///
/// A `UIVisualEffectView` is the only thing that hands you a layer able to filter the
/// content underneath it in real time, so one is used here purely for that layer. Its own
/// blur and tint are dismantled: the layer's filters are replaced by the variable blur,
/// and the tinting subviews are made invisible so that no hard edge is left behind.
///
/// > Warning: This reaches ``BackdropBlurFilter``, which is private API. See ``GlurView``.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, visionOS 1.0, *)
open class GlurBackdropUIView: UIVisualEffectView {
    private var radius: CGFloat
    private var glurMask: GlurMask
    private var layoutDirection: LayoutDirection

    private var backdropLayer: CALayer? {
        subviews.first?.layer
    }

    public init(radius: CGFloat, mask: GlurMask, layoutDirection: LayoutDirection = .leftToRight) {
        self.radius = radius
        self.glurMask = mask
        self.layoutDirection = layoutDirection

        super.init(effect: UIBlurEffect(style: .regular))

        guard BackdropBlurFilter() != nil else {
            NSLog("[Glur] Error: the backdrop blur filter is unavailable")
            return
        }

        subviews.dropFirst().forEach { $0.alpha = 0.0 }

        applyParameters()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the effect in place.
    public func update(radius: CGFloat, mask: GlurMask, layoutDirection: LayoutDirection) {
        self.radius = radius
        self.glurMask = mask
        self.layoutDirection = layoutDirection

        applyParameters()
    }

    /// A layer keeps its own copy of each filter it's given, so changing one it already has
    /// does nothing on screen. Every change hands it a new filter instead.
    private func applyParameters() {
        guard let filter = BackdropBlurFilter() else { return }
        filter.apply(radius: radius, mask: glurMask.cgImage(layoutDirection: layoutDirection))

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backdropLayer?.filters = [filter.object]
        CATransaction.commit()
    }

    open override func didMoveToWindow() {
        guard let window else { return }
        backdropLayer?.setBackdropScale(window.traitCollection.displayScale)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Deliberately not calling super: it restores the effect's own filters, which
        // replaces the blur on every appearance change.
    }
}

#endif
