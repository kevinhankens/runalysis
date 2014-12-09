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
    
    /*!
     * Overrides UIViewController::viewDidLoad()
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        var ypos = CGFloat(70)
        
        let container = UIScrollView(frame: CGRectMake(0, 20, self.view.frame.width, self.view.frame.height - 20))
        
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
            ypos += iconSize + 10
            i++
        }
        container.addSubview(orientation)
        
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
    
    func orientationSelect(sender: UISegmentedControl) {
        println("\(sender.selectedSegmentIndex)")
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
        return false
    }
    
    /*!
     *
     */
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    /*!
     *
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}