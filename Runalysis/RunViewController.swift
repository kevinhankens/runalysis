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
    
    var routeStore: RouteStore?
    
    var routeId: NSNumber = 0
    
    var runView: RunView?
    
    var routeAnalysisView: RouteAnalysisView?
    
    // Tracks the container for scrolling/zooming.
    var scrollContainer: UIScrollView?
    
    // The height of the content to scroll.
    var scrollContentHeight = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = UIScrollView(frame: CGRectMake(0, 20, self.view.frame.width, self.view.frame.height - 20))
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(20)
        
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(0, ypos, container.bounds.width/2, 35.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.titleLabel?.font = UIFont.systemFontOfSize(30.0)
        backButton.titleLabel?.textAlignment = NSTextAlignment.Left
        backButton.setTitleColor(GlobalTheme.getBackButtonTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchDown)
        container.addSubview(backButton)
        
        ypos = ypos + backButton.frame.height + 10
        
        let routeId = Int(NSDate().timeIntervalSince1970)
        
        let routeSummary = RouteSummary.createRouteSummary(routeId, routeStore: self.routeStore!)
        
        let r = RunView.createRunView(0, y: ypos, cellHeight: container.bounds.width, cellWidth: container.bounds.width, routeStore: self.routeStore!, locationManager: self.locationManager!, routeSummary: routeSummary)
        self.runView = r
        container.addSubview(r)
        
        ypos = ypos + r.frame.height + 10
        
        self.scrollContentHeight = ypos //+ CGFloat(rav.frame.height)
        self.scrollContainer = container
        self.view.addSubview(container)
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
        return Int(UIInterfaceOrientationMask.Portrait.toRaw())
    }
    
    /*!
    *
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
