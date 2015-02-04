//
//  ImageUtils.swift
//  RandomMemories
//
//  Created by Baptiste Truchot on 1/30/15.
//  Copyright (c) 2015 Bap. All rights reserved.
//

import UIKit
import AssetsLibrary

class ImageUtils: NSObject {
    
    class func convertToImageOrientation(orientation : ALAssetOrientation) -> UIImageOrientation? {
        return UIImageOrientation(rawValue: orientation.rawValue)!
    }
    
    class func outerGlow(view: UIView) -> () {
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOffset = CGSizeMake(0.0, 0.0)
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.5
        view.layer.masksToBounds = false
    }
}
