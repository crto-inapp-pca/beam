//
//  CriteoWindow.swift
//  beam
//
//  Created by Romain Lofaso on 10/14/20.
//  Copyright © 2020 Awkward. All rights reserved.
//

import UIKit

class CriteoWindow: UIWindow {

   override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return pointInView(view: self, inside: point, with: event)
    }
    
    func pointInView(view: UIView, inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in view.subviews {
            if  NSStringFromClass(type(of: subview.self)) == "UITransitionView" ||
                NSStringFromClass(type(of: subview.self)) == "UIDropShadowView" {
                let result = pointInView(view: subview, inside: point, with: event)
                if (result) {
                    return result
                }
                continue
            }
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }

}
