//
//  BlurDirection.swift
//  
//
//  Created by João Gabriel Pozzobon dos Santos on 09/02/24.
//

import SwiftUI

public enum BlurDirection: Int {
    case down = 0
    case up = 1
    case right = 2
    case left = 3
    
    var unitPoints: (UnitPoint, UnitPoint) {
        switch self {
        case .down:
            return (.top, .bottom)
        case .up:
            return (.bottom, .top)
        case .right:
            return (.leading, .trailing)
        case .left:
            return (.trailing, .leading)
        }
    }
}

