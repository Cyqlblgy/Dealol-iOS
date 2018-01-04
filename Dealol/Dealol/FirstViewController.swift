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
            print("URL string", url)
            var searchString: String = ""
            if url.contains("www.amazon.com") && url.contains("/dp/"){
                let range1 = url.range(of: "www.amazon.com/")?.upperBound
                let range2 = url.range(of: "/dp/")?.lowerBound
                searchString = url.substring(with: range1..<range2)
                searchString = searchString.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
            }
            else if url.contains("www.walmart.com/ip/"){
                let stringArray = url.split(separator: "/")
                if stringArray.count > 2{
                    searchString = String(stringArray[stringArray.count-2])
                }
                searchString = searchString.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
            }
            print("search string:", searchString)
            if searchString.count == 0{
                let alert = UIAlertController(title: "Please try again", message: "You search is not valid", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else{
                NSLog("Search text: %@",searchString)
                let searchResultVC = self.storyboard?.instantiateViewController(withIdentifier: "searchResultVC") as! SearchResultViewController
                searchResultVC.searchString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                self.navigationController?.pushViewController(searchResultVC, animated: true)
            }
        }
    }
}

