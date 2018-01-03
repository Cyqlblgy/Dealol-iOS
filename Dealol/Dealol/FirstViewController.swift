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
        var act: DealActivity = DealActivity()
        return [act]
    }
}

