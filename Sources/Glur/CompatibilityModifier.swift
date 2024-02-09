//
//  CompatibilityView.swift
//
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//

import SwiftUI

internal struct CompatibilityModifier: ViewModifier {
    public var offset: CGFloat
    public var interpolation: CGFloat
    public var radius: CGFloat
    public var direction: BlurDirection
    
    func body(content: Content) -> some View {
        content
            .overlay {
                content
                    .drawingGroup()
                    .allowsHitTesting(false)
                    .blur(radius: radius)
                    .scaleEffect(1+(radius*0.02))
                    .mask(gradientMask)
            }
    }
    
    var gradientMask: some View {
        var startPoint: UnitPoint
        var endPoint: UnitPoint
        
        switch direction {
        case .down:
            startPoint = .top
            endPoint = .bottom
        case .up:
            startPoint = .bottom
            endPoint = .top
        case .right:
            startPoint = .leading
            endPoint = .trailing
        case .left:
            startPoint = .trailing
            endPoint = .leading
        }
        
        
        return LinearGradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: offset),
            .init(color: .black, location: offset+interpolation)
        ],
                       startPoint: startPoint,
                       endPoint: endPoint)
    }
}
