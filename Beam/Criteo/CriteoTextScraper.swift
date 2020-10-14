//
//  CriteoTextScraper.swift
//  beam
//
//  Created by Vincent Guerci on 14/10/2020.
//  Copyright © 2020 Awkward. All rights reserved.
//

import UIKit

extension UIView {
    func scrapeTextRecursively() -> String? {
        var texts = [String]()
        if accessibilityTraits.intersection([.adjustable, .header]).isEmpty,
           let trimmedLabel = accessibilityLabel?.trimmingCharacters(in: .whitespacesAndNewlines),
           !trimmedLabel.isEmpty {
            texts.append(trimmedLabel)
        }
        if !subviews.isEmpty {
            texts.append(contentsOf: subviews.reversed().compactMap({ $0.scrapeTextRecursively() }))
        }
        return texts.isEmpty ? nil : texts.joined(separator: "\n")
    }
}
