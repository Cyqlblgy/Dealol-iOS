//
//  FirstViewController.swift
//  Dealol
//
//  Created by Bin Lang on 5/22/17.
//  Copyright © 2017 Dealol. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        NSLog("Search text: %@",searchBar.text!)
        let searchResultVC = self.storyboard?.instantiateViewController(withIdentifier: "searchResultVC") as! SearchResultViewController
        searchResultVC.searchString = searchBar.text!
        self.navigationController?.pushViewController(searchResultVC, animated: true)
    }
}

