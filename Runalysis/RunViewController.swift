//
//  RunViewController.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/21/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class RunViewController: UIViewController {
    
    // Tracks the Core Location Manager.
    var locationManager: CLLocationManager?
    
    // Tracks the RouteStore object.
    var routeStore: RouteStore?
    
    // Tracks the id of the viewed route.
    var routeId: NSNumber = 0
    
    // Tracks the RunView object.
    var runView: RunView?
    
    // Tracks the RouteAnalysisView.
    var routeAnalysisView: RouteAnalysisView?
    
    // Tracks the container for scrolling/zooming.
    var scrollContainer: UIScrollView?
    
    // The height of the content to scroll.
    var scrollContentHeight = CGFloat(0)
    
    // @todo this should be in a central place.
    let orientationKey = "RunalysisRunViewOrientation"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var boundsWidth = CGFloat(0.0)
        var boundsHeight = CGFloat(0.0)
        
        let currentOrientation = UIApplication.sharedApplication().statusBarOrientation
        
        boundsWidth = self.view.bounds.width
        boundsHeight = self.view.bounds.height
        
        // If it is in portrait and the preferred orientation is landscape,
        // we need to flip the bounds.
        if currentOrientation == UIInterfaceOrientation.Portrait {
            switch self.getOrientation() {
            case 1, 2:
                boundsWidth = self.view.bounds.height
                boundsHeight = self.view.bounds.width
            default:
                boundsWidth = self.view.bounds.width
                boundsHeight = self.view.bounds.height
            }
        }
        
       
        let container = UIScrollView(frame: CGRectMake(0, 20, boundsWidth, boundsHeight - 20))
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(50)
        
        let routeId = Int(NSDate().timeIntervalSince1970)
        
        let routeSummary = RouteSummary.createRouteSummary(routeId, routeStore: self.routeStore!)
        
        let r = RunView.createRunView(0, y: ypos, cellHeight: container.bounds.width, cellWidth: container.bounds.width, routeStore: self.routeStore!, locationManager: self.locationManager!, routeSummary: routeSummary)
        self.runView = r
        container.addSubview(r)
        
        ypos = ypos + r.frame.height + 10
        
        self.scrollContentHeight = ypos //+ CGFloat(rav.frame.height)
        self.scrollContainer = container
        self.view.addSubview(container)
        
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(10, 30, container.bounds.width/2, 35.00)
        backButton.setTitle("< Back/Save", forState: UIControlState.Normal)
        backButton.titleLabel?.sizeToFit()
        backButton.titleLabel?.font = UIFont.systemFontOfSize(30.0)
        backButton.titleLabel?.textAlignment = NSTextAlignment.Left
        backButton.setTitleColor(GlobalTheme.getBackButtonTextColor(), forState: UIControlState.Normal)
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        backButton.backgroundColor = GlobalTheme.getBackButtonBgColor()
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchDown)
        backButton.sizeToFit()
        self.view.addSubview(backButton)
    }
    
    /*!
    * Implements UIViewController::viewWillAppear:animated
    */
    override func viewWillAppear(animated: Bool) {
        if let container = self.scrollContainer? {
            container.contentSize = CGSizeMake(self.view.bounds.width, self.scrollContentHeight)
        }
    }
    
    /*!
    * Handles the button press to return to the root view.
    */
    func returnToRootView(sender: UIButton) {
        self.runView!.recording = false
        self.runView?.locationManager?.stopUpdatingLocation()
        self.routeStore?.saveContext()
        self.runView!.locationManager!.delegate = nil
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
        return Int(UIInterfaceOrientationMask.Portrait.rawValue) |
            Int(UIInterfaceOrientationMask.LandscapeLeft.rawValue) |
            Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        
        
        switch self.getOrientation() {
        case 1:
            return UIInterfaceOrientation.LandscapeRight
        case 2:
            return UIInterfaceOrientation.LandscapeLeft
        default:
            return UIInterfaceOrientation.Portrait
        }
    }
    
    func getOrientation()->Int {
        return NSUserDefaults.standardUserDefaults().integerForKey(self.orientationKey)
    }
    
    /*!
    *
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
