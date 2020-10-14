//
//  CriteoEmptyView.swift
//  beam
//
//  Created by Romain Lofaso on 10/14/20.
//  Copyright © 2020 Awkward. All rights reserved.
//

import UIKit

class CriteoRootView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0)
    }
    
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews {
            if !subview.isHidden && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }

}
