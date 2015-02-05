//
//  MemoryViewController.swift
//  RandomMemories
//
//  Created by Baptiste Truchot on 1/29/15.
//  Copyright (c) 2015 Bap. All rights reserved.
//

import UIKit
import AssetsLibrary
import CoreLocation

class MemoryViewController: UIViewController {

    
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blurView: UIImageView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // color
        colorArray = [UIColor.whiteColor()]
//        [UIColor.whiteColor(),UIColor.lightGrayColor(),UIColor.redColor(),UIColor.greenColor(),UIColor.blueColor(),UIColor.cyanColor(),UIColor.orangeColor(),UIColor.purpleColor(),UIColor.brownColor(),UIColor.magentaColor(),UIColor.yellowColor()]
        self.pickColorRandomly()
        
        // labels
        self.logoImageView.alpha = 0
        self.cityLabel.hidden = true
        self.dateLabel.hidden = true
        self.authLabel.hidden = true
        self.welcomeLabel.alpha = 0
        self.tutoLabel.alpha = 0
        self.welcomeLabel.text = "Welcome to your memories"
        self.tutoLabel.text = "Tap to remember"
        self.authLabel.text = "You need to allow " + ConstantUtils.appTitle() + " to access your photos"
        
        // image view
        self.imageView.userInteractionEnabled = true
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.blurView.contentMode = UIViewContentMode.ScaleAspectFill
        
        // Tap gesture
        let aSelector : Selector = "changePhotoAndColor"
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        self.imageView.addGestureRecognizer(tapGesture)
        self.blurView.alpha = 0
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
                        var timer: NSTimer?
                        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("changePhotoAndColor"), userInfo: nil, repeats: false)
                })
            }
        }
    }

    
    func pickRandomPhoto(success succeed: (UIImage?,NSDate?,CLLocation?) -> () = { image in }, failure fail : NSError -> () = {error in }) {
        var assetLib:ALAssetsLibrary = ALAssetsLibrary()
        
        assetLib.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos), usingBlock: {
            (group: ALAssetsGroup?, stop: UnsafeMutablePointer<ObjCBool>) in
            if group != nil {
                group!.setAssetsFilter(ALAssetsFilter.allPhotos())
                let r = Int(arc4random_uniform(UInt32(group!.numberOfAssets())))
                group!.enumerateAssetsAtIndexes(NSIndexSet(index: r), options: nil, usingBlock: {
                    (result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                    if (result != nil) {
                        let alAssetRepresentation = result.defaultRepresentation()
                        let orientation = ImageUtils.convertToImageOrientation(alAssetRepresentation.orientation())
                        let metaData = alAssetRepresentation.metadata()
                        var date: NSDate? = result.valueForProperty(ALAssetPropertyDate) as? NSDate
                        var loc: CLLocation? = result.valueForProperty(ALAssetPropertyLocation) as? CLLocation
                        var image = UIImage(CGImage: alAssetRepresentation.fullResolutionImage().takeUnretainedValue(), scale: 1, orientation: orientation!)
                        succeed(image,date,loc)
                    }
                })
            }
        }, failureBlock: {  (error: NSError!) in
            if (self.authLabel.hidden) {
                self.authLabel.hidden = false
            } else {
                GeneralUtils.openSettings()
            }
            fail(error)
        })
    }
    
    func changePhotoAndColor() {
//        pickColorRandomly()
        self.tutoLabel.alpha = 0
        self.welcomeLabel.alpha = 0
        self.logoImageView.hidden = true
        changeRandomPhoto()
    }
    
    func changeRandomPhoto() {
        self.titleView.alpha = 0
        self.dateLabel.text = ""
        self.cityLabel.text = ""
        UIView.animateWithDuration(0, animations: {
            self.blurView.alpha = 1
            }, completion: { (finished) in
                self.pickRandomPhoto { image,date,loc in
                    if (image != nil) {
                        self.imageView.image = image
                        self.lastDate = date
                        self.lastLocation = loc
                        if (loc != nil) {
                            self.geoCoder.reverseGeocodeLocation(loc) { placemark,error in
                                if (placemark != nil) {
                                    let place = placemark[0] as CLPlacemark
                                    self.cityLabel.text = (place.addressDictionary["City"] as NSString) + " (" + place.country + ")"
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
                            dateFormatter.dateFormat = "MMM yy"
                            self.dateLabel.text = dateFormatter.stringFromDate(date!)
                            self.dateLabel.hidden = false
                        } else {
                            self.dateLabel.hidden = true
                        }
                        UIGraphicsBeginImageContext(self.view.bounds.size)
                        self.imageView.image!.drawInRect(CGRectMake(0,0,self.view.bounds.size.width,self.view.bounds.size.height))
                        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        self.blurView.image = screenshot.applyLightEffect()
                        UIView.animateWithDuration(0, animations: {
                            self.blurView.alpha = 0
                        })
                    }
                }

        })
    }

    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func animateWhiteBorder(completion: () -> ()) {
        let middleTop = CGPointMake(self.view.frame.size.width / 2, 0);
        let rightTop = CGPointMake(self.view.frame.size.width, 0);
        let rightBottom = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
        let leftBottom = CGPointMake(0, self.view.frame.size.height);
        let leftTop = CGPointMake(0, 0);
        
        self.layer1.frame = self.view.frame
        self.layer1.strokeColor = self.currentColor.CGColor;
        self.layer1.lineWidth = 6;
        var path1 = UIBezierPath()
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
        var path2 = UIBezierPath()
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
        var pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
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
        self.currentColor = self.colorArray[randomIndex] as UIColor
        self.cityLabel.textColor = self.currentColor
        self.dateLabel.textColor = self.currentColor
        self.view.layer.borderColor = self.currentColor.CGColor
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.layer1.removeFromSuperlayer()
        self.layer2.removeFromSuperlayer()
    }
}
