//
//  BrowseViewController.swift
//  Dealol
//
//  Created by Bin Lang on 1/14/18.
//  Copyright © 2018 Dealol. All rights reserved.
//

import UIKit
import WebKit

class BrowseViewController: UIViewController {
    var webView: WKWebView!
    var urlString: String = ""
    var trackButton: UIBarButtonItem!
    var browseItem: [String : Any] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dealol"
        // loading URL :
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        
        // init and load request in webview.
        webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView.load(request)
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        trackButton = UIBarButtonItem.init(title: "Track", style: UIBarButtonItemStyle.plain, target: self, action: #selector(trackURL))
        self.navigationItem.rightBarButtonItem = trackButton
    }
    
    @objc private func trackURL(){
        (UIApplication.shared.delegate as! AppDelegate).tempResult.append(browseItem)
        let alert = UIAlertController(title: "Success", message: "You have added to your tracking list", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Tracking List", style: UIAlertActionStyle.default, handler:{(alert: UIAlertAction!) in
            self.tabBarController?.selectedIndex = 1
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func goBack(){
        self.navigationController?.popViewController(animated: false)
    }
}

extension BrowseViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        trackButton.isEnabled = false
        print("Strat to load" + (webView.url?.absoluteString)!)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        trackButton.isEnabled = UtilHelper.isValidURLString((webView.url?.absoluteString)!)
        print("finish to load" + (webView.url?.absoluteString)!)
    }
}
