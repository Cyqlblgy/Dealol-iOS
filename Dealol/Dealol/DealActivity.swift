//
//  DealActivity.swift
//  Dealol
//
//  Created by Lang, Bin on 1/1/18.
//  Copyright © 2018 Dealol. All rights reserved.
//

import UIKit

class DealActivity: UIActivity {
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
        //
    }
    
    override func perform() {
        activityDidFinish(true)
    }
}
