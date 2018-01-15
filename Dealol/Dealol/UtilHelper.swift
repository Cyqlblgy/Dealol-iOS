//
//  UtilHelper.swift
//  Dealol
//
//  Created by Bin Lang on 1/14/18.
//  Copyright © 2018 Dealol. All rights reserved.
//

import UIKit

class UtilHelper: NSObject {
    static func isValidURLString(_ urlString : String)->Bool{
        if (urlString.contains("www.amazon.com") && urlString.contains("/dp/"))
            || urlString.contains("www.walmart.com/ip/"){
            return true
        }
        else{
            return false
        }
    }
}
