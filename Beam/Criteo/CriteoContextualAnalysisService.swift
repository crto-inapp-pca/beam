//
//  CriteoContextualAnalysisService.swift
//  beam
//
//  Created by Vincent Guerci on 14/10/2020.
//  Copyright © 2020 Awkward. All rights reserved.
//

import Foundation

typealias Classification = [String: NSNumber]

protocol CriteoContextualAnalysisService {
    func scrape() -> String 
    func classify(content: String, completion block: @escaping (Classification) -> Void)
    func getProductImageURLs(classification: Classification, completion block: @escaping ([URL]) -> Void)
}


class CriteoContextualAnalysisServiceMock: CriteoContextualAnalysisService {
    
    func scrape() -> String {
        return "Lorem ipsum dolor sit amet, consectetur adipiscing elit,\nsed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,\n\nsunt in culpa qui officia deserunt mollit anim id est laborum."
    }
    
    func classify(content: String, completion block: @escaping (Classification) -> Void) {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.global().asyncAfter(deadline: deadlineTime, execute: {
            block([
                "Sport": 0.98,
                "Furniture": 0.6,
                "Dressing": 0.2222,
                "Politic": 0.0,
                "Luxe": 0.4,
            ])
        })
    }
    
    func getProductImageURLs(classification: Classification, completion block: @escaping ([URL]) -> Void) {
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.global().asyncAfter(deadline: deadlineTime, execute: {
            block([
                URL(string:"https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRSqN3mZVdRrRNrxOGcuY6jJ38iD5reu3Lykm0zFP5LAetmu85WGNfIMnbDTwk&usqp=CAc")!,
                URL(string:"https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRkeu3BXCpTtIHMDZLZvdc68ZGfCQPoJnX_b1az3PblQOiBtA0heeuQHBJlatlvXz4llExpYRk&usqp=CAc")!,
                URL(string:"https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcT-zwJdibWAbKqecDDQrEZmrzCngcTfV-sx4OPaDCMZq2exC3qlNNfBBJue4qDEOuieo-FZ78KQ&usqp=CAc")!
            ])
        })
    }
    
}
