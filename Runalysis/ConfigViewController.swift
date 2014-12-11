//
//  ConfigViewController.swift
//  Runalysis
//
//  Created by Kevin Hankens on 12/9/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class ConfigViewController: UIViewController {
    
    let orientationKey = "RunalysisRunViewOrientation"
    let unitsKey = "RunalysisUnits"
    
    /*!
     * Overrides UIViewController::viewDidLoad()
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        var ypos = CGFloat(20)
        
        let container = UIScrollView(frame: CGRectMake(0, ypos, self.view.frame.width, self.view.frame.height - 20))
        
        ypos += 50
        
        let orientationLabel = UILabel(frame: CGRectMake(10, ypos, container.bounds.width - 20, GlobalTheme.getNormalFontHeight()))
        orientationLabel.text = "Rotate when running"
        orientationLabel.textColor = GlobalTheme.getNormalTextColor()
        orientationLabel.font = GlobalTheme.getNormalFont()
        orientationLabel.textAlignment = NSTextAlignment.Center
        container.addSubview(orientationLabel)
        
        ypos += orientationLabel.frame.height + 10
        
        let orientationValue = NSUserDefaults.standardUserDefaults().integerForKey(self.orientationKey)
        
        let iconSize = CGFloat(72)
        var orientation = UISegmentedControl()
        orientation.tintColor = GlobalTheme.getRunTextColor()
        orientation.frame = CGRectMake(10, ypos, self.view.frame.width - 20, iconSize + 10)
        orientation.addTarget(self, action: "orientationSelect:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Configure the run view orientation.
        // Add the review button
        let icons = ["PhoneIconNormal", "PhoneIconLeft", "PhoneIconRight"]
        var i = 0
        for icon in icons {
            var image = UIImage(named: icon)
            orientation.insertSegmentWithImage(image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), atIndex: i, animated: true)
            i++
        }
        orientation.selectedSegmentIndex = orientationValue
        container.addSubview(orientation)
        
        ypos += orientation.frame.height + 10
        
        let unitsLabel = UILabel(frame: CGRectMake(10, ypos, container.bounds.width - 20, GlobalTheme.getNormalFontHeight()))
        unitsLabel.text = "Display units"
        unitsLabel.textColor = GlobalTheme.getNormalTextColor()
        unitsLabel.font = GlobalTheme.getNormalFont()
        unitsLabel.textAlignment = NSTextAlignment.Center
        container.addSubview(unitsLabel)
        
        ypos += unitsLabel.frame.height + 10
        
        let unitsValue = NSUserDefaults.standardUserDefaults().integerForKey(self.unitsKey)
        var units = UISegmentedControl()
        units.tintColor = GlobalTheme.getRunTextColor()
        units.frame = CGRectMake(10, ypos, self.view.frame.width - 20, GlobalTheme.getNormalFontHeight() + 10)
        units.addTarget(self, action: "unitsSelect:", forControlEvents: UIControlEvents.ValueChanged)
        units.insertSegmentWithTitle("Miles", atIndex: 0, animated: true)
        units.insertSegmentWithTitle("Kilometers", atIndex: 1, animated: true)
        units.selectedSegmentIndex = unitsValue
        container.addSubview(units)
        
        self.view.addSubview(container)
        
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(10, 30, self.view.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.titleLabel?.sizeToFit()
        backButton.titleLabel?.font = UIFont.systemFontOfSize(30.0)
        backButton.titleLabel?.textAlignment = NSTextAlignment.Left
        backButton.setTitleColor(GlobalTheme.getBackButtonTextColor(), forState: UIControlState.Normal)
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        backButton.backgroundColor = GlobalTheme.getBackButtonBgColor()
        backButton.addTarget(self, action: "returnToRootViewButton:", forControlEvents: UIControlEvents.TouchDown)
        backButton.sizeToFit()
        self.view.addSubview(backButton)
    }
    
    /*!
     * Handler for the orientation segmented control actions.
     *
     * Saves the choice to the NSUserDefaults.
     *
     * @param sender
     */
    func orientationSelect(sender: UISegmentedControl) {
        NSUserDefaults.standardUserDefaults().setInteger(sender.selectedSegmentIndex, forKey: self.orientationKey)
        NSUserDefaults.standardUserDefaults().synchronize()
 
    }
    
     /*!
      * Handler for the units segmented control actions.
      *
      * Saves the choice to the NSUserDefaults.
      *
      * @param sender
      */
    func unitsSelect(sender: UISegmentedControl) {
        NSUserDefaults.standardUserDefaults().setInteger(sender.selectedSegmentIndex, forKey: self.unitsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /*!
     * Handles the button press to return to the root view.
     */
    func returnToRootViewButton(sender: UIButton) {
        self.returnToRootView()
    }
    
    /*!
     * Dismisses this view controller to return to the root view.
     */
    func returnToRootView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*!
     *
     */
    override func shouldAutorotate()->Bool {
        return true
    }
    
    /*!
     *
     */
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue) |
            Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue) |
            Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
    }
    
    /*!
     *
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}