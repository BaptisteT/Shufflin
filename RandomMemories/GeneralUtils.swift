//
//  GeneralUtils.swift
//  RandomMemories
//
//  Created by Baptiste Truchot on 2/5/15.
//  Copyright (c) 2015 Bap. All rights reserved.
//

import UIKit

class GeneralUtils: NSObject {
    
    class func openSettings () {
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
            case .OrderedSame, .OrderedDescending:
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            default:
                break
        }
    }
    
    class func isFirstOpening () -> Bool {
        let prefs = NSUserDefaults.standardUserDefaults()
        let firstOpeningPref = "First Opening Pref"
        if (prefs.boolForKey(firstOpeningPref)) {
            return false
        } else {
            prefs.setBool(true, forKey: firstOpeningPref)
            return true
        }
    }
}
