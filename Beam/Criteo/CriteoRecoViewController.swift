//
//  CriteoRecoViewController.swift
//  beam
//
//  Created by Romain Lofaso on 10/14/20.
//  Copyright © 2020 Awkward. All rights reserved.
//

import UIKit
import SDWebImage

class CriteoRecoViewController: UITableViewController {
    var topController: UIViewController?
    
    static let LoadingCellId = "LoadingCellId"
    static let ClassificationCellId = "ClassificationCellId"
    static let ProductCellId = "ProductCellId"
    static let headers = ["Products", "Contextual analysis", "Scraping"]
    
    var service: CriteoContextualAnalysisService?
    var scrapped: String?
    var sortedClassification: [(String, Float)]?
    var products: [CriteoProduct]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Criteo Recommendation"
        
        self.tableView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: CriteoRecoViewController.LoadingCellId)
        self.tableView.register(UINib(nibName: "CriteoClassificationCell", bundle: nil), forCellReuseIdentifier: CriteoRecoViewController.ClassificationCellId)
        self.tableView.register(UINib(nibName: "CriteoProductCell", bundle: nil), forCellReuseIdentifier: CriteoRecoViewController.ProductCellId)
        self.tableView.register(UITableViewCell.self)
        self.service = CriteoContextualAnalysisServiceImplementation(topController: topController)
        self.scrapped = self.service?.scrape()
        self.service?.classify(content: self.scrapped!, completion: { (classification) in
            DispatchQueue.main.async {
                let topCategories = classification.sorted(by: { $0.value > $1.value }).prefix(10)
                let maxWeight = topCategories.map(\.value).max()!
                let prettifiedCategories = topCategories.map { key, value -> (String, Float) in
                    let name = key.dropFirst(3).replacingOccurrences(of: "_", with: " ").capitalized
                    let scaledValue = value / maxWeight
                    return (name, scaledValue)
                }
                self.sortedClassification = Array(prettifiedCategories)
                self.tableView.reloadData()
            }
            self.service?.getProducts(for: classification) { products in
                DispatchQueue.main.async {
                    self.products = products
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return CriteoRecoViewController.headers.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return CriteoRecoViewController.headers[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && self.products != nil {
            return self.products!.count
        }
        
        if section == 1 && self.sortedClassification != nil {
            return self.sortedClassification!.count
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && self.products != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: CriteoRecoViewController.ProductCellId, for: indexPath) as! CriteoProductCell
            let product = products![indexPath.row]
            cell.nameLabel?.text = product.name
            cell.categoryLabel?.text = product.productURL?.host
            cell.productImageView?.sd_setImage(with: product.imageURL, placeholderImage: UIImage(named: "criteo_button"))
            return cell
        }
        
        if indexPath.section == 1 && self.sortedClassification != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: CriteoRecoViewController.ClassificationCellId, for: indexPath) as! CriteoClassificationCell
            let cat = self.sortedClassification![indexPath.row]
            cell.categoryLabel?.text = cat.0
            cell.progress?.progress = cat.1
            return cell
        }
        
        if indexPath.section == 2 && !(self.scrapped?.isEmpty ?? true) {
            let cell = tableView.dequeueReusable(UITableViewCell.self, for: indexPath)
            cell.textLabel?.text = self.scrapped
            cell.textLabel?.numberOfLines = 0;
            cell.textLabel?.lineBreakMode = .byWordWrapping;
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CriteoRecoViewController.LoadingCellId)! as! ActivityCell
        cell.indicator?.startAnimating()
        return cell
    }
}
