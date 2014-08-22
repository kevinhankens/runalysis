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
    
    // If there was an error.
    var errorCaught: Bool = false
    
    // Tracks the route storage engine.
    var routeStore: RouteStore?
    
    let routeId = Int(NSDate().timeIntervalSince1970)
    
    // Tracks the current location.
    var currentLat = CLLocationDegrees(0)
    var currentLon = CLLocationDegrees(0)
    
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
     * @return RunView
     */
    class func createRunView(cellHeight: CGFloat, cellWidth:
        CGFloat, routeStore: RouteStore, locationManager: CLLocationManager)->RunView {
            
        let runView = RunView(frame: CGRect(x: 0, y: 50, width: cellWidth, height: cellHeight))
            
        runView.routeStore = routeStore
            
        locationManager.startUpdatingLocation()
        locationManager.delegate = runView
        runView.locationManager = locationManager
        if let l = locationManager.location {
            runView.currentLat = l.coordinate.latitude.advancedBy(Double(0.0))
            runView.currentLon = l.coordinate.longitude.advancedBy(Double(0.0))
        }
            
        var ypos: CGFloat = 10
            
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
            let routeView = RouteView.createRouteView(0, y: ypos, width: runView.bounds.width, height: runView.bounds.width, routeId: runView.routeId, routeStore: routeStore)
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
        var distance: Double = 0
        var velocity: Double = 0
        
        if self.recording {
            if (locationObj.timestamp.timeIntervalSince1970 - self.lastUpdateTime > self.updateInterval) {
                let updateTime = locationObj.timestamp.timeIntervalSince1970
                    if (self.currentLat != 0 && self.currentLon != 0) && self.currentLat != coord.latitude || currentLon != coord.longitude {
                        
                        // Velocity calculation
                        if self.lastUpdateTime > 0 && self.currentLat != 0 && currentLon != 0 {
                            distance = sqrt(Double(pow(fabs(currentLat - coord.latitude), 2)) + Double(pow(fabs(currentLon - coord.longitude), 2)))
                            velocity = distance/(Double(updateTime) - Double(self.lastUpdateTime))
                        }
                    
                        // Write to db.
                        // @todo use a timer to account for pauses.
                        var route = self.routeStore!.storeRoutePoint(self.routeId, date: Int(updateTime), latitude: coord.latitude, longitude: coord.longitude, altitude: locationObj.altitude, velocity: velocity)
                        // Redraw the map
                        if let rv = self.routeView as? RouteView {
                            //rv.changeRoute(self.routeId)
                            rv.points.append(route)
                            rv.displayLatest()
                        }
                        
                        self.lastUpdateTime = updateTime.advancedBy(Double(0.0))
                        self.currentLat = coord.latitude.advancedBy(Double(0.0))
                        self.currentLon = coord.longitude.advancedBy(Double(0.0))
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
    
}
