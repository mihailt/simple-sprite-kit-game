//
//  CGFloatsExtensions.swift
//  Game
//
//  Created by Mihails Tumkins on 27/02/15.
//  Copyright (c) 2015 Mihails Tumkins. All rights reserved.
//

import Foundation
import CoreGraphics

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    static func random(#min:CGFloat, max:CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}