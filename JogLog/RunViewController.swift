//
//  RunViewController.swift
//  JogLog
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(30)
        
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(0, ypos, self.view.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(backButton)
        
        ypos = ypos + backButton.frame.height + 10
        
        let routeId = Int(NSDate().timeIntervalSince1970)
        
        let routeSummary = RouteSummary.createRouteSummary(routeId, routeStore: self.routeStore!)
        
        let r = RunView.createRunView(self.view.bounds.width, cellWidth: self.view.bounds.width, routeStore: self.routeStore!, locationManager: self.locationManager!, routeSummary: routeSummary)
        self.runView = r
        self.view.addSubview(r)
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
        return Int(UIInterfaceOrientation.Portrait.toRaw())
    }
    
    /*!
    *
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}