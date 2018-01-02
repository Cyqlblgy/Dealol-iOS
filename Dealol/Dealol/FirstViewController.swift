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
        walmartButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        walmartButton.layer.masksToBounds = false
        walmartButton.layer.shadowRadius = 1.0
        walmartButton.layer.shadowOpacity = 0.5
        walmartButton.layer.cornerRadius = walmartButton.frame.width / 2
        
        amazonButton.layer.shadowColor = UIColor.black.cgColor
        amazonButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        amazonButton.layer.masksToBounds = false
        amazonButton.layer.shadowRadius = 1.0
        amazonButton.layer.shadowOpacity = 0.5
        amazonButton.layer.cornerRadius = amazonButton.frame.width / 2
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
            present(vc, animated: true)
        } else {
            // Fallback on earlier versions
        }
    }
}

