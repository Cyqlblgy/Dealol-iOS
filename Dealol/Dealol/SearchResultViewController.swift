//
//  SearchResultViewController.swift
//  Dealol
//
//  Created by Lang, Bin on 1/1/18.
//  Copyright © 2018 Dealol. All rights reserved.
//

import UIKit
class SearchResultCell : UITableViewCell{
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var reviewImage: UIImageView!
    @IBOutlet weak var numReview: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
}

class SearchResultViewController: UIViewController {
    var searchString: String!
    var searchResult = [String: Any]()
    @IBOutlet weak var searchTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
    }
    
    private func fetchData(){
        let todosEndpoint: String = "http://dealol-dealol.7e14.starter-us-west-2.openshiftapps.com/deals/search?productName=" + searchString + "&start=1"
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
                print(error)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                guard let receivedTodo = try JSONSerialization.jsonObject(with: responseData,
                                                                          options: []) as? [String: Any] else {
                                                                            print("Could not get JSON from responseData as dictionary")
                                                                            return
                }
                print("The todo is: " + receivedTodo.description)
                self.searchResult = receivedTodo
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                }
            } catch  {
                print("error parsing response from POST on /todos")
                return
            }
        }
        task.resume()
    }
}

extension SearchResultViewController: UITableViewDelegate{
    
}

extension SearchResultViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResult.isEmpty {
            return 0
        }
        else{
            return searchResult["totalNumber"] as! Int
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as! SearchResultCell
        let result: [String: AnyObject] = (searchResult["resultDeals"] as! Array)[indexPath.row] as [String: AnyObject]
        if !result.isEmpty {
            cell.nameLabel.text = result["itemName"] as? String
            if let price = result["itemPrice"] as? Double{
                cell.priceLabel.text = String(price)
            }
            else{
                cell.priceLabel.text = nil
            }
            if let num = result["numberOfReviews"] as? Int{
                cell.numReview.text = String(num)
            }
            else{
                cell.numReview.text = nil
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
                }
                if let range = subRate.range(of: ".") {
                    subRate.replaceSubrange(range, with: "_")
                    let rateString = "http://i2.walmartimages.com/i/CustRating/" + subRate + ".gif"
                    let data = try? Data(contentsOf: URL(string: rateString)!)
                    cell.reviewImage.image = UIImage(data: data!)
                }
            }
        }
        return cell
    }
}
