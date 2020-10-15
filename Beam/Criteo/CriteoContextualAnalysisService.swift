//
//  CriteoContextualAnalysisService.swift
//  beam
//
//  Created by Vincent Guerci on 14/10/2020.
//  Copyright © 2020 Awkward. All rights reserved.
//

import UIKit
import Alamofire

let inAppPcaEndpoint = "https://pubcontent-pcainapp.par.preprod.crto.in/in-app"

typealias Classification = [String: Float]

protocol CriteoContextualAnalysisService {
    func scrape() -> String 
    func classify(content: String, completion block: @escaping (Classification) -> Void)
    func getProductImageURLs(classification: Classification, completion block: @escaping ([URL]) -> Void)
}

struct CriteoContextualAnalysisServiceImplementation: CriteoContextualAnalysisService {

    // MARK: - Scraper

    let topController: UIViewController?

    func scrape() -> String {
        let texts = topController?.view.scrapeTextsRecursively() ?? []
        let filtered = texts.filter { (text) -> Bool in
            text.split(characterSet: CharacterSet.whitespaces).count > 3
        }
        return filtered.joined(separator: "\n")
    }

    // MARK: - Classifier

    func classify(content: String, completion block: @escaping (Classification) -> Void) {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.global().asyncAfter(deadline: deadlineTime, execute: {
            block([
                "gs_event_mothers_day": 0.98,
                "gs_travel_holidays": 0.6,
                "gs_auto_luxury": 0.2222,
                "gs_sport_baseball": 0.4,
                "gs_tech_computing": 0.0,
            ])
        })
    }

    // MARK: - Product Images

    struct InAppParameters: Codable {
        let categories: [String]
        let partnerId: Int
        let productCount: Int
        let platform: String
        let country: String

        init(categories: [String], partnerId: Int = 725, productCount: Int = 3, platform: String = "EU", country: String = "FR") {
            self.categories = categories
            self.partnerId = partnerId
            self.productCount = productCount
            self.platform = platform
            self.country = country
        }
    }

    func getProductImageURLs(classification: Classification, completion block: @escaping ([URL]) -> Void) {
        let top3Categories = classification.sorted(by: { $0.value > $1.value }).prefix(3).map ({ $0.key })
        let parameters = InAppParameters(categories: top3Categories)
        AF.request(inAppPcaEndpoint, method: .post, parameters: parameters, encoder: JSONParameterEncoder.prettyPrinted)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON as NSDictionary):
                    let products = JSON["products"]! as! NSArray
                    let bigImages: [String] = products.map { product in
                        (product as! NSDictionary)["BigImage"] as! String
                    }
                    let bigImagesURLs = bigImages.map({ URL(string: $0)! })
                    block(bigImagesURLs)
                default:
                    print("whoops")
                }
            }
    }
    
}
