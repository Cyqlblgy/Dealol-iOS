//
//  FirstViewController.swift
//  Dealol
//
//  Created by Bin Lang on 5/22/17.
//  Copyright © 2017 Dealol. All rights reserved.
//

import UIKit
import SafariServices

class FirstViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var walmartButton: UIButton!
    @IBOutlet weak var amazonButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.setImage(UIImage.init(named: "search"), for:.search, state: .normal)
        walmartButton.layer.shadowColor = UIColor.black.cgColor
        walmartButton.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        walmartButton.layer.shadowRadius = 5.0
        walmartButton.layer.shadowOpacity = 0.5
        
        amazonButton.layer.shadowColor = UIColor.black.cgColor
        amazonButton.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        amazonButton.layer.shadowRadius = 5.0
        amazonButton.layer.shadowOpacity = 0.5
        amazonButton.isHidden = true
    }

    @IBAction func goAmazon(_ sender: Any) {
        showTutorial(1)
    }
    
    @IBAction func goWalmart(_ sender: Any) {
        showTutorial(2)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        if searchBar.text?.count == 0 {
            return
        }
        NSLog("Search text: %@",searchBar.text!)
        let searchResultVC = self.storyboard?.instantiateViewController(withIdentifier: "searchResultVC") as! SearchResultViewController
        searchResultVC.searchString = searchBar.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        searchResultVC.brandName = "";
        self.navigationController?.pushViewController(searchResultVC, animated: true)
    }
    
    private func showTutorial(_ which: Int) {
        let url = which == 1 ? "https://www.amazon.com" : "https://www.walmart.com"
        if #available(iOS 11.0, *) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc = SFSafariViewController(url: URL.init(string: url)!, configuration: config)
            vc.delegate = self;
            present(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
}

extension FirstViewController: SFSafariViewControllerDelegate{
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        let act: DealActivity = DealActivity()
        act.dealProtocol = self
        return [act]
    }
}

extension FirstViewController: DealActivityProtocol{
    func done(_ url: String) {
        dismiss(animated: false) {
            if UtilHelper.isValidURLString(url){
                var productId: String = ""
                var searchString: String = ""
                var source: String = ""
                if url.contains("www.amazon.com") && url.contains("/dp/"){
                    let stringArray = url.split(separator: "/")
                    if stringArray.count > 4{
                        productId = String(stringArray[4])
                    }
                    let range1 = url.range(of: "www.amazon.com/")?.upperBound
                    let range2 = url.range(of: "/dp/")?.lowerBound
                    searchString = url.substring(with: range1..<range2)
                    searchString = searchString.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
                    source = "Amazon"
                }
                else if url.contains("www.walmart.com/ip/"){
                    let stringArray = url.split(separator: "/")
                    if stringArray.count > 4{
                        productId = String(stringArray[4])
                        searchString = String(stringArray[stringArray.count-2])
                    }
                    source = "Walmart"
                }
                print("productId: ", productId)
                print("filterString: ", searchString)
                self.fetchKeywordsString(productId,source,searchString)
            }
            else{
                self.showInvalidSearch()
            }
        }
    }
    
    private func fetchKeywordsString(_ productId: String, _ source: String, _ filterString: String){
        //"http://dealol-dealol.193b.starter-ca-central-1.openshiftapps.com/deal?id="
        // "http://localhost:3000/deal?id="
        let todosEndpoint: String = "http://dealol-dealol.193b.starter-ca-central-1.openshiftapps.com/deal?id=" + productId + "&source=" + source
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
                print("error calling GET on deal?")
                self.showInvalidSearch()
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                self.showInvalidSearch()
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
                if let keywords = temp["keywords"] as? String{
                    NSLog("keywords : %@",keywords)
                    DispatchQueue.main.async {
                        let searchResultVC = self.storyboard?.instantiateViewController(withIdentifier: "searchResultVC") as! SearchResultViewController
                        searchResultVC.searchString = keywords.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                        if let branName = temp["brandName"] as? String{
                            searchResultVC.brandName = branName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                        }
                        else{
                            searchResultVC.brandName = ""
                        }
                        if let price = temp["price"] as? Double{
                            searchResultVC.price = Int(price)
                        }
                        if let categoryID = temp["categoryID"] as? String{
                            searchResultVC.categoryId = categoryID
                        }
                        searchResultVC.walmartTemp = temp;
                        self.navigationController?.pushViewController(searchResultVC, animated: true)
                    }
                }
                else{
                    self.showInvalidSearch()
                }
            } catch  {
                print("error parsing response from GET on deal?")
                self.showInvalidSearch()
                return
            }
        }
        task.resume()
    }
    
    private func showInvalidSearch(){
        let alert = UIAlertController(title: "Please try again", message: "You search is not valid", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

