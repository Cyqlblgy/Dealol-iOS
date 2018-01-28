//
//  SecondViewController.swift
//  Dealol
//
//  Created by Bin Lang on 5/22/17.
//  Copyright © 2017 Dealol. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var savedTableView: UITableView!
    var count: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        savedTableView.tableFooterView = UIView()
        savedTableView.register(UINib.init(nibName: "TrackingTableViewCell", bundle: nil), forCellReuseIdentifier: "trackCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if count == 0 || count != (UIApplication.shared.delegate as! AppDelegate).tempResult.count{
            savedTableView.reloadData()
        }
    }
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        count = (UIApplication.shared.delegate as! AppDelegate).tempResult.count
        return count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackingTableViewCell
        let result = (UIApplication.shared.delegate as! AppDelegate).tempResult[indexPath.row]
        if !result.isEmpty {
            cell.nameLabel.text = result["itemName"] as? String
            if let price = result["itemPrice"] as? Double{
                cell.priceLabel.text = String(price)
            }
            else{
                cell.priceLabel.text = nil
            }
            if let name = result["source"] as? String{
                cell.companyImage.image = UIImage.init(named: name)
            }
            
            if let logoString = result["itemImage"] as? String{
                let url = URL(string: logoString)
                let data = try? Data(contentsOf: url!)
                cell.logoImage.image = UIImage(data: data!)
            }
            if let rate = result["customerRate"] as? String {
                var subRate = rate.substring(to: rate.index(rate.startIndex, offsetBy:3))
                if subRate[rate.index(rate.startIndex, offsetBy:2)] == "0" {
                    subRate = rate.substring(to: rate.index(rate.startIndex, offsetBy:1))
                    let rateString = "http://i2.walmartimages.com/i/CustRating/" + subRate + ".gif"
                    let data = try? Data(contentsOf: URL(string: rateString)!)
                    cell.reviewImage.image = UIImage(data: data!)
                }
                else if let range = subRate.range(of: ".") {
                    subRate.replaceSubrange(range, with: "_")
                    let rateString = "http://i2.walmartimages.com/i/CustRating/" + subRate + ".gif"
                    let data = try? Data(contentsOf: URL(string: rateString)!)
                    cell.reviewImage.image = UIImage(data: data!)
                }
            }
            else{
                let rateString = "http://i2.walmartimages.com/i/CustRating/0.gif"
                let data = try? Data(contentsOf: URL(string: rateString)!)
                cell.reviewImage.image = UIImage(data: data!)
            }
        }
        return cell
    }
}


