//
//  MemoryViewController.swift
//  RandomMemories
//
//  Created by Baptiste Truchot on 1/29/15.
//  Copyright (c) 2015 Bap. All rights reserved.
//

import Foundation
import UIKit
import Photos
import CoreLocation

class MemoryViewController: UIViewController {

    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    var layer1 = CAShapeLayer()
    var layer2 = CAShapeLayer()
    var geoCoder = CLGeocoder()
    var colorArray = NSArray()
    var currentColor = UIColor.whiteColor()
    var lastDate: NSDate?
    var lastLocation: CLLocation?
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var tutoLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    var fetchResult : PHFetchResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color
        colorArray = [UIColor.whiteColor(),UIColor.lightGrayColor(),UIColor.redColor(),UIColor.greenColor(),UIColor.blueColor(),UIColor.cyanColor(),UIColor.orangeColor(),UIColor.purpleColor(),UIColor.brownColor(),UIColor.magentaColor(),UIColor.yellowColor()]
        self.pickColorRandomly()
        
        // Fetch result
        self.fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        
        // labels
        self.logoImageView.alpha = 0
        self.cityLabel.hidden = true
        self.dateLabel.hidden = true
        self.authLabel.hidden = true
        self.welcomeLabel.alpha = 0
        self.tutoLabel.alpha = 0
        self.welcomeLabel.text = "Welcome to your memories"
        self.tutoLabel.text = "Tap the screen\nand start traveling"
        self.authLabel.text = "You need to allow " + ConstantUtils.appTitle() + " to access your photos"
        
        // image view
        self.imageView.userInteractionEnabled = true
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("changePhotoAndColor"))
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.animateWhiteBorder{
            self.view.layer.borderWidth = 3
            self.view.layer.borderColor = self.currentColor.CGColor
            
            if GeneralUtils.isFirstOpening() {
                UIView.animateWithDuration(1, animations: {
                    self.welcomeLabel.alpha = 1
                    }, completion: { (completed) in
                        UIView.animateWithDuration(1, animations: {
                            self.logoImageView.alpha = 1
                            }, completion: { (completed) in
                                UIView.animateWithDuration(1, animations: {
                                    self.tutoLabel.alpha = 1
                                })
                        })
                })
            } else {
                UIView.animateWithDuration(1, animations: {
                    self.logoImageView.alpha = 1
                    }, completion: { (completed) in
                        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("changePhotoAndColor"), userInfo: nil, repeats: false)
                })
            }
        }
    }

    
    func pickRandomPhoto(success: (UIImage?,NSDate?,CLLocation?) -> () = { image in }) {
        let imgManager = PHImageManager.defaultManager()
        let requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = false
        
        if self.fetchResult.count > 0 {
            let r = Int(arc4random_uniform(UInt32(self.fetchResult.count)))
            let asset : PHAsset = fetchResult.objectAtIndex(r) as! PHAsset
            imgManager.requestImageForAsset(asset, targetSize: self.view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, info) in
                    success(image,asset.creationDate,asset.location)
                })
        }
    }
    
    func changePhotoAndColor() {
        pickColorRandomly()
        self.tutoLabel.alpha = 0
        self.welcomeLabel.alpha = 0
        self.logoImageView.hidden = true
        changeRandomPhoto()
    }
    
    func changeRandomPhoto() {
        self.titleView.alpha = 0
        self.dateLabel.text = ""
        self.cityLabel.text = ""
        self.pickRandomPhoto ({ image,date,loc in
            if (image != nil) {
                self.imageView.image = image
                self.lastDate = date
                self.lastLocation = loc
                if (loc != nil) {
                    self.geoCoder.reverseGeocodeLocation(loc!) { placemark,error in
                        if (placemark != nil) {
                            let place = placemark![0] as CLPlacemark
                            let country = (place.country != nil) ? place.country! : ""
                            let city = (place.addressDictionary?["City"] != nil) ? place.addressDictionary!["City"] as! String : ""
                            self.cityLabel.text = city + " (" + country + ")"
                            self.cityLabel.hidden = false
                            self.titleView.hidden = false
                            UIView.animateWithDuration(0.5, animations: {self.titleView.alpha = 1})
                        }
                    }
                } else {
                    self.cityLabel.hidden = true
                }
                if (date != nil) {
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd MMM yy"
                    self.dateLabel.text = dateFormatter.stringFromDate(date!)
                    self.dateLabel.hidden = false
                } else {
                    self.dateLabel.hidden = true
                }
            }
        })
    }

    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func animateWhiteBorder(completion: () -> ()) {
        let middleTop = CGPointMake(self.view.frame.size.width / 2, 0)
        let rightTop = CGPointMake(self.view.frame.size.width, 0)
        let rightBottom = CGPointMake(self.view.frame.size.width, self.view.frame.size.height)
        let leftBottom = CGPointMake(0, self.view.frame.size.height)
        let leftTop = CGPointMake(0, 0)
        
        self.layer1.frame = self.view.frame
        self.layer1.strokeColor = self.currentColor.CGColor
        self.layer1.lineWidth = 6;
        let path1 = UIBezierPath()
        path1.moveToPoint(middleTop)
        path1.addLineToPoint(rightTop)
        path1.addLineToPoint(rightBottom)
        path1.addLineToPoint(leftBottom)
        path1.addLineToPoint(leftTop)
        path1.closePath()
        self.layer1.path = path1.CGPath
        self.layer1.fillColor = UIColor.clearColor().CGColor
        
        self.layer2.strokeColor = self.currentColor.CGColor
        self.layer2.lineWidth = 6
        let path2 = UIBezierPath()
        path2.moveToPoint(middleTop)
        path2.addLineToPoint(leftTop)
        path2.addLineToPoint(leftBottom)
        path2.addLineToPoint(rightBottom)
        path2.addLineToPoint(rightTop)
        path2.closePath()
        self.layer2.path = path2.CGPath;
        self.layer2.fillColor = UIColor.clearColor().CGColor
        
        self.view.layer.addSublayer(self.layer1)
        self.view.layer.addSublayer(self.layer2)
        
        CATransaction.begin()
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 2
        pathAnimation.fromValue = 0
        pathAnimation.toValue = 0.5
        CATransaction.setCompletionBlock(completion)
        self.layer1.addAnimation(pathAnimation, forKey: "strokeEndAnimation")
        self.layer2.addAnimation(pathAnimation, forKey: "strokeEndAnimation")
        CATransaction.commit()
    }
    
    func pickColorRandomly() -> () {
        let randomIndex = Int(arc4random()) % self.colorArray.count
        self.currentColor = self.colorArray[randomIndex] as! UIColor
        self.cityLabel.textColor = self.currentColor
        self.dateLabel.textColor = self.currentColor
        self.view.layer.borderColor = self.currentColor.CGColor
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.layer1.removeFromSuperlayer()
        self.layer2.removeFromSuperlayer()
    }
}
