//
//  RunView.swift
//  JogLog
//
//  Created by Kevin Hankens on 8/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class RunView: UIView, CLLocationManagerDelegate {
    
    // Tracks the Core Location Manager.
    var locationManager: CLLocationManager?
    
    // Tracks the parent view controller.
    var parent: ViewController?
    
    // If there was an error.
    var errorCaught: Bool = false
    
    // Tracks the route storage engine.
    var routeStore: RouteStore = RouteStore()
    
    let routeId = Int(NSDate().timeIntervalSince1970)
    
    // Tracks the current location.
    var current: CLLocationCoordinate2D?
    
    var lastUpdateTime: NSTimeInterval = 0.0
    
    let updateInterval: NSTimeInterval = 4.0
    
    var recording: Bool = false
    
    var routeView: RouteView?
    
    /*!
     * Factory method to create a RunView.
     *
     * @param CGFloat cellHeight
     *
     * @param CGFloat cellWidth
     *
     * @param ViewController parent
     *
     * @return RunView
     */
    class func createRunView(cellHeight: CGFloat, cellWidth:
        CGFloat, parent: ViewController? = nil)->RunView {
            
        let runView = RunView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight))
            
        runView.parent = parent
            
        var lm = CLLocationManager()
        lm.delegate = runView
        lm.desiredAccuracy = kCLLocationAccuracyBest
        // IOS7 does not respond.
        if lm.respondsToSelector(Selector("requestAlwaysAuthorization")) {
            lm.requestAlwaysAuthorization()
        }
        lm.startUpdatingLocation()
        runView.locationManager = lm
        runView.current = lm.location?.coordinate
            
        var ypos: CGFloat = 10
            
        // Back button to dismiss this view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(10, ypos, runView.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.sizeToFit()
        backButton.addTarget(runView, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchUpInside)
        runView.addSubview(backButton)
            
        ypos = ypos + backButton.frame.height + 20
            
        // Control button for recording the run.
        let record = UIButton()
        record.frame = CGRectMake(10, ypos, runView.bounds.width/2, 20.00)
        record.setTitle("Start", forState: UIControlState.Normal)
        record.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        record.backgroundColor = GlobalTheme.getBackgroundColor()
        //record.sizeToFit()
        record.addTarget(runView, action: "toggleRecordPause:", forControlEvents: UIControlEvents.TouchUpInside)
        runView.addSubview(record)
            
        ypos = ypos + record.frame.height + 20
            
        // Create a RouteView to display the results.
        let routeView = RouteView.createRouteView(0, y: ypos, width: runView.bounds.width, height: runView.bounds.width, routeId: runView.routeId)
        runView.routeView = routeView
            
        runView.addSubview(routeView)
           
        return runView
    }
    
    /*!
     * Handles the record/pause button action.
     *
     * @param UIButton sender
     */
    func toggleRecordPause(sender: UIButton) {
        if self.recording {
            self.recording = false
            sender.setTitle("Start", forState: UIControlState.Normal)
        }
        else {
            self.recording = true
            sender.setTitle("Pause", forState: UIControlState.Normal)
        }
    }
    
    /*!
     * Converts a coordinate pair to a string.
     *
     * @param CLLocationCoordinate2D coord
     *
     * @return NSString
     */
    func coordToString(coord: CLLocationCoordinate2D)->NSString {
        return "lat: \(coord.latitude) x long: \(coord.longitude)"
    }
    
    /*!
     * CLLocationManager delegate.
     *
     * Handles the change of location.
     *
     * @return void
     */
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
        
        if self.recording {
            if (locationObj.timestamp.timeIntervalSince1970 - self.lastUpdateTime > self.updateInterval) {
                self.lastUpdateTime = locationObj.timestamp.timeIntervalSince1970
                if let c = self.current as? CLLocationCoordinate2D {
                    if c.latitude != coord.latitude || c.longitude != coord.longitude {
                        self.current = coord
                        // Write to db.
                        // @todo use a timer to account for pauses.
                        self.routeStore.storeRoutePoint(self.routeId, date: self.lastUpdateTime, latitude: coord.latitude, longitude: coord.longitude, altitude: locationObj.altitude, velocity: 0)
                        // Redraw the map
                        if let rv = self.routeView as? RouteView {
                            rv.changeRoute(rv.routeId)
                        }
                    }
                }
            }
        }
    }
    
    /*!
     * CLLocationManager delegate.
     *
     * Handles an error
     *
     * @return void
     */
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        self.locationManager?.stopUpdatingLocation()
        if (error) {
            if (self.errorCaught == false) {
                self.errorCaught = true
                print(error)
            }
        }
    }
    
    /*!
     * Handles the return to root.
     *
     * @param UIButton sender
     *
     * @return void
     */
    func returnToRootView(sender: UIButton) {
        self.locationManager?.stopUpdatingLocation()
        
        // Stop running and roll the rocker cells down in the parent view.
        if let p = self.parent as? ViewController {
            p.view.endEditing(true)
            p.rollCellsDown()
            if let b = p.runButton as? UIButton {
                // @todo this is a bit gross.
                b.alpha = 1.0
            }
        }
        
        self.removeFromSuperview()
    }

}
