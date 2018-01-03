//
//  DealActivity.swift
//  Dealol
//
//  Created by Lang, Bin on 1/1/18.
//  Copyright © 2018 Dealol. All rights reserved.
//

import UIKit

protocol DealActivityProtocol {
    func done(_ url: String)
}

class DealActivity: UIActivity {
    var dealProtocol: DealActivityProtocol? = nil
    override class var activityCategory: UIActivityCategory {
        return .action
    }
    
    override var activityType: UIActivityType? {
        guard let bundleId = Bundle.main.bundleIdentifier else {return nil}
        return UIActivityType(rawValue: bundleId + "\(self.classForCoder)")
    }
    
    override var activityTitle: String? {
        return "Dealol"
    }
    
    override var activityImage: UIImage? {
        return UIImage.init(named:"icon")
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        for obj in activityItems{
            if obj is URL{
                let url:URL = obj as! URL
                if dealProtocol != nil {
                    dealProtocol!.done(url.absoluteString)
                }
            }
        }
    }
    
    override func perform() {
        activityDidFinish(true)
    }
}
