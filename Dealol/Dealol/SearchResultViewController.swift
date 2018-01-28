//
//  SearchResultViewController.swift
//  Dealol
//
//  Created by Lang, Bin on 1/1/18.
//  Copyright © 2018 Dealol. All rights reserved.
//

import UIKit
import SafariServices

class SearchResultCell : UITableViewCell{
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var reviewImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyImage: UIImageView!
}

class SearchResultViewController: UIViewController {
    var searchString: String!
    var brandName: String!
    var searchPage: Int = 0
    var totalResult = [Dictionary<String, Any>]()
    var maxNumber: Int = 0
    var price: Int = 0
    let refreshControl = UIRefreshControl()
    @IBOutlet weak var searchTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dealol"
        self.searchTableView.tableFooterView = UIView()
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            self.searchTableView.refreshControl = self.refreshControl
        } else {
            self.searchTableView.addSubview(self.refreshControl)
        }
        self.refreshControl.tintColor = UIColor.black
        self.refreshControl.attributedTitle = NSAttributedString(string: "Fetching Result ...", attributes: [NSForegroundColorAttributeName: UIColor.black])
        self.refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        self.searchTableView.contentOffset = CGPoint.init(x: 0, y: -self.refreshControl.frame.size.height);
        self.refreshControl.sendActions(for: .valueChanged)
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        searchPage = 0
        fetchData(true)
    }
    
    @objc private func goBack(){
        self.navigationController?.popViewController(animated: false)
    }
    
    func fetchData(_ needtoStartAndEnd: Bool){
        if needtoStartAndEnd{
            DispatchQueue.main.async {
                print("Start fetching")
                self.refreshControl.beginRefreshing()
                self.searchTableView.setContentOffset(CGPoint(x: 0, y: self.searchTableView.contentOffset.y-self.refreshControl.frame.size.height), animated: true)
                
            }
        }
        self.searchPage += 1
        var todosEndpoint: String = "http://dealol-dealol.7e14.starter-us-west-2.openshiftapps.com/deals/search?keywords=" + searchString + "&page=" + String(self.searchPage)
        
        //var todosEndpoint: String = "http://localhost:3000/deals/search?keywords=" + searchString + "&page=" + String(self.searchPage)
        if brandName.count > 0 {
            todosEndpoint = todosEndpoint + "&brandName=" + brandName
        }
        if price > 0 {
            todosEndpoint = todosEndpoint + "&price=" + String(price)
        }
        NSLog("Search URL: %@", todosEndpoint)
        guard let todosURL = URL(string: todosEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        var todosUrlRequest = URLRequest(url: todosURL)
        todosUrlRequest.httpMethod = "GET"
        let session = URLSession.shared
        
        let task = session.dataTask(with: todosUrlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                DispatchQueue.main.async {
                    print("End fetching")
                    self.refreshControl.endRefreshing()
                }
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                DispatchQueue.main.async {
                    print("End fetching")
                    self.refreshControl.endRefreshing()
                }
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                guard let receivedTodo = try JSONSerialization.jsonObject(with: responseData,
                                                                          options: []) as? [String: Any] else {
                                                                            print("Could not get JSON from responseData as dictionary")
                                                                            return
                }
                print("The result is: " + receivedTodo.description)
                var temp: [String: Any] = receivedTodo
                if needtoStartAndEnd{
                    self.totalResult = temp["resultDeals"] as! Array
                    let amazon: Int = temp["amazonTotal"] as! Int
                    let walmart: Int = temp["walmartTotal"] as! Int
                    self.maxNumber = amazon + walmart
                }
                else{
                    self.totalResult.append(contentsOf: temp["resultDeals"] as! Array)
                }
                DispatchQueue.main.async {
                    if needtoStartAndEnd{
                        print("End fetching")
                        self.refreshControl.endRefreshing()
                    }
                    self.searchTableView.reloadData()
                }
            } catch  {
                print("error parsing response from GET on /todos")
                DispatchQueue.main.async {
                    print("End fetching")
                    self.refreshControl.endRefreshing()
                }
                return
            }
        }
        task.resume()
    }
}

extension SearchResultViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false);
        let result = self.totalResult[indexPath.row]
        if !result.isEmpty, let urlString = result["itemURL"] as? String{
            let bvc = self.storyboard?.instantiateViewController(withIdentifier: "browseViewController") as! BrowseViewController
            bvc.urlString = urlString
            bvc.browseItem = self.totalResult[indexPath.row] 
            self.navigationController?.pushViewController(bvc, animated: true)
        }
    }
}

extension SearchResultViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalResult.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! SearchResultCell
        let result = self.totalResult[indexPath.row]
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
        if indexPath.row == self.totalResult.count-1 && indexPath.row < maxNumber - 1 {
           NSLog("Total: %d, current: %d", maxNumber, indexPath.row)
           fetchData(false)
        }
        return cell
    }
}
