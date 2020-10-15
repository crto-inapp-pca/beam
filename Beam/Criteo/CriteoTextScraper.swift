//
//  CriteoTextScraper.swift
//  beam
//
//  Created by Vincent Guerci on 14/10/2020.
//  Copyright © 2020 Awkward. All rights reserved.
//

import UIKit

extension UIView {
    func scrapeText() -> String? {
        if accessibilityTraits.intersection([.adjustable, .header]).isEmpty,
           let trimmedLabel = accessibilityLabel?.trimmingCharacters(in: .whitespacesAndNewlines),
           !trimmedLabel.isEmpty {
            return trimmedLabel
        }
        return nil
    }

    func scrapeTextsRecursively() -> [String] {
        var texts = [String]()
        if let scraped = scrapeText() {
            texts.append(scraped)
        }
        if !subviews.isEmpty {
            let subviewsTexts = subviews.reversed().flatMap({ $0.scrapeTextsRecursively() })
            texts.append(contentsOf: subviewsTexts)
        }
        return texts
    }
}
