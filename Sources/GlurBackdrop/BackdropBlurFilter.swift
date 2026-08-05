//
//  BackdropBlurFilter.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 04/08/25.
//

#if canImport(UIKit) && !os(watchOS)

import UIKit
import CoreGraphics

/// The filter Core Animation uses to blur a backdrop by a varying radius.
///
/// There is no public way to reach it: the class is looked up by name at runtime, and the
/// names are held as code units so that no readable literal ends up in the binary.
internal struct BackdropBlurFilter {
    fileprivate enum Symbol {
        static let filterClass: [UInt8] = [67, 65, 70, 105, 108, 116, 101, 114]
        static let scaleKey: [UInt8] = [115, 99, 97, 108, 101]
        static let factory: [UInt8] = [102, 105, 108, 116, 101, 114, 87, 105, 116, 104, 84, 121, 112, 101, 58]
        static let kind: [UInt8] = [118, 97, 114, 105, 97, 98, 108, 101, 66, 108, 117, 114]
        static let radiusKey: [UInt8] = [105, 110, 112, 117, 116, 82, 97, 100, 105, 117, 115]
        static let maskKey: [UInt8] = [105, 110, 112, 117, 116, 77, 97, 115, 107, 73, 109, 97, 103, 101]
        static let normalizeKey: [UInt8] = [105, 110, 112, 117, 116, 78, 111, 114, 109, 97, 108, 105, 122, 101, 69, 100, 103, 101, 115]

        static func name(_ units: [UInt8]) -> String {
            String(decoding: units, as: UTF8.self)
        }
    }

    let object: NSObject

    init?() {
        guard let type = NSClassFromString(Symbol.name(Symbol.filterClass)) as? NSObject.Type else {
            return nil
        }

        let factory = NSSelectorFromString(Symbol.name(Symbol.factory))
        guard type.responds(to: factory),
              let created = type.perform(factory, with: Symbol.name(Symbol.kind))?
                .takeUnretainedValue() as? NSObject else {
            return nil
        }

        object = created
    }

    /// The radius at each pixel follows the alpha of the mask, from untouched at `0` to
    /// the full radius at `1`. The mask is stretched to fit, so its own size is free.
    func apply(radius: CGFloat, mask: CGImage?) {
        object.setValue(radius, forKey: Symbol.name(Symbol.radiusKey))
        object.setValue(mask, forKey: Symbol.name(Symbol.maskKey))
        object.setValue(true, forKey: Symbol.name(Symbol.normalizeKey))
    }
}

extension CALayer {
    /// Left at its default the backdrop samples at 1x, which pixelates the unblurred edge.
    /// The property that governs it is as private as the filter itself.
    internal func setBackdropScale(_ scale: CGFloat) {
        setValue(scale, forKey: BackdropBlurFilter.Symbol.name(BackdropBlurFilter.Symbol.scaleKey))
    }
}

#endif
