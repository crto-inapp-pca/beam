//
//  CriteoTextScraper.swift
//  beam
//
//  Created by Vincent Guerci on 14/10/2020.
//  Copyright © 2020 Awkward. All rights reserved.
//

import UIKit

extension UIView {
    func scrapeTextsRecursively() -> [String] {
        var texts = [String]()
        if accessibilityTraits.intersection([.adjustable, .header]).isEmpty,
           let trimmedLabel = accessibilityLabel?.trimmingCharacters(in: .whitespacesAndNewlines),
           !trimmedLabel.isEmpty {
            texts.append(trimmedLabel)
        }
        if !subviews.isEmpty {
            texts.append(contentsOf: subviews.reversed().flatMap({ $0.scrapeTextsRecursively() }))
        }
        return texts
    }
}
