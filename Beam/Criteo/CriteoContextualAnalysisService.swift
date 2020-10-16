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
    func getProducts(for classification: Classification, completion block: @escaping ([CriteoProduct]) -> Void)
}

struct CriteoContextualAnalysisServiceImplementation: CriteoContextualAnalysisService {

    // MARK: - Properties

    let topController: UIViewController?
    let classifier: CriteoNLClassifier
    let bertClassifier: CriteoBERTNLClassifier

    // MARK: - Lifecycle

    init(topController: UIViewController?) {
        classifier = CriteoNLClassifier()
        classifier.loadModel()
        bertClassifier = CriteoBERTNLClassifier()
        bertClassifier.loadModel()
        self.topController = topController
    }

    // MARK: - Scraper

    func scrape() -> String {
        let texts = topController?.view.scrapeTextsRecursively() ?? []
        let filtered = texts.filter { (text) -> Bool in
            text.split(characterSet: CharacterSet.whitespaces).count > 3
        }
        return filtered.joined(separator: "\n")
    }

    // MARK: - Classifier

    func classify(content: String, completion block: @escaping (Classification) -> Void) {
        DispatchQueue.global().async {
            //let classificationArr = self.classifier.classify(text: content)
            let classificationArr = self.bertClassifier.classify(text: content)
            let classifier = classificationArr.reduce(into: [String: Float]()) { $0[$1.key] = $1.value.floatValue }
            block(classifier)
        }
    }

    // MARK: - Products

    func getProducts(for classification: Classification, completion block: @escaping ([CriteoProduct]) -> Void) {
        let topCategories = classification.sorted(by: { $0.value > $1.value }).prefix(1).map ({ $0.key })
        let partnerId = topCategories.filter { $0.contains("travel") }.isEmpty ? 725 : 1169
        let parameters = InAppParameters(categories: topCategories, partnerId: partnerId)
        AF.request(inAppPcaEndpoint, method: .post, parameters: parameters, encoder: JSONParameterEncoder.prettyPrinted)
            .responseJSON { response in
                switch response.result {
                case .success(let JSON as NSDictionary):
                    let productsJSON = JSON["products"]! as! NSArray
                    let products: [CriteoProduct] = productsJSON.map { productJSON in
                        CriteoProduct(dictionary: productJSON as! NSDictionary)
                    }
                    block(products)
                default:
                    print("whoops")
                }
            }
    }
    
}

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

struct CriteoProduct {
    let name: String
    let category: String
    let imageURL: URL?

    init(name: String, category: String, imageURL: URL?) {
        self.name = name
        self.category = category
        self.imageURL = imageURL
    }

    init(dictionary: NSDictionary) {
        name = dictionary["Name"] as? String ?? ""
        category = dictionary["ProductType"] as? String ?? ""
        if let bigImage = dictionary["BigImage"] as? String {
            imageURL = URL(string: bigImage)
        } else {
            imageURL = nil
        }
    }
}

struct CriteoContextualAnalysisServiceMock: CriteoContextualAnalysisService {
    let topController: UIViewController?

    func scrape() -> String {
        let texts = topController?.view.scrapeTextsRecursively() ?? []
        let filtered = texts.filter { (text) -> Bool in
            text.split(characterSet: CharacterSet.whitespaces).count > 3
        }
        return filtered.joined(separator: "\n")
    }
    
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
    
    func getProducts(for classification: Classification, completion block: @escaping ([CriteoProduct]) -> Void) {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.global().asyncAfter(deadline: deadlineTime, execute: {
            block([
                CriteoProduct(
                    name: "Product 1", category: "Category 1",
                    imageURL: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRSqN3mZVdRrRNrxOGcuY6jJ38iD5reu3Lykm0zFP5LAetmu85WGNfIMnbDTwk&usqp=CAc")),
                CriteoProduct(
                    name: "Product 1", category: "Category 1",
                    imageURL: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRkeu3BXCpTtIHMDZLZvdc68ZGfCQPoJnX_b1az3PblQOiBtA0heeuQHBJlatlvXz4llExpYRk&usqp=CAc")),
                CriteoProduct(
                    name: "Product 1", category: "Category 1",
                    imageURL: URL(string: "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT-zwJdibWAbKqecDDQrEZmrzCngcTfV-sx4OPaDCMZq2exC3qlNNfBBJue4qDEOuieo-FZ78KQ&usqp=CAc")),
            ])
        })
    }
    
}
