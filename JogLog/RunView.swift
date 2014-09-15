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
    
    // Tracks the previous location.
    var prev = CLLocation()
    
    var lastUpdateTime: NSTimeInterval = 0.0
    
    let updateInterval: NSTimeInterval = 4.0
    
    var recording: Bool = false
    
    var routeView: RouteView?
    
    var routeAnalysisView: RouteAnalysisView?
    
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
        CGFloat, routeStore: RouteStore, locationManager: CLLocationManager, routeSummary: RouteSummary)->RunView {
            
        let runView = RunView(frame: CGRect(x: 0, y: 50, width: cellWidth, height: cellHeight))
            
        runView.routeStore = routeStore
            
        locationManager.startUpdatingLocation()
        locationManager.delegate = runView
        runView.locationManager = locationManager
        if let l = locationManager.location {
            runView.prev = RunView.createLocationCopy(l)
        }
            
        var ypos: CGFloat = 10
            
        // Control button for recording the run.
        let record = UIButton()
        record.frame = CGRectMake(0, ypos, runView.bounds.width, 45.00)
        record.setTitle("Start", forState: UIControlState.Normal)
        record.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        record.titleLabel.font = UIFont.systemFontOfSize(40.0)
        //record.backgroundColor = GlobalTheme.getBackgroundColor()
        //record.sizeToFit()
        record.addTarget(runView, action: "toggleRecordPause:", forControlEvents: UIControlEvents.TouchUpInside)
        runView.addSubview(record)
            
        //ypos += record.frame.height + 10
            
        // Create a RouteView to display the results.
        let routeView = RouteView.createRouteView(0, y: ypos, width: runView.bounds.width, height: runView.bounds.width, routeId: runView.routeId, routeStore: routeStore, routeSummary: routeSummary)
        runView.routeView = routeView
        runView.addSubview(routeView)
            
        ypos = ypos + routeView.frame.height + 10
            
        // @todo what is the height of this view?
        let rav = RouteAnalysisView.createRouteAnalysisView(40.0, cellWidth: runView.bounds.width, x: 0, y: ypos, routeSummary: routeSummary)
        runView.addSubview(rav)
        runView.routeAnalysisView = rav
        rav.userInteractionEnabled = false
            
        record.frame.origin.y = routeView.frame.minY + (routeView.frame.height/2)
        runView.bringSubviewToFront(record)
          
        return runView
    }

    /*!
     * Creates a copy of a specified location.
     *
     * @param CLLocation location
     *
     * @return CLLocation
     */
    class func createLocationCopy(location: CLLocation)->CLLocation {
        var newLocation = CLLocation(coordinate: location.coordinate, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, speed: location.speed, timestamp: location.timestamp)
        return newLocation
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
        var alt = locationObj.altitude
        var hdistance: Double = 0
        var distance: Double = 0
        var velocity: Double = 0
        
        if self.recording {
            if (locationObj.timestamp.timeIntervalSince1970 - self.lastUpdateTime > self.updateInterval) {
                let updateTime = locationObj.timestamp.timeIntervalSince1970
                if (self.prev.coordinate.latitude != coord.latitude || self.prev.coordinate.longitude != coord.longitude) {
                        
                    // Velocity calculation
                    if (self.lastUpdateTime > 0 && self.prev.coordinate.latitude != 0 && self.prev.coordinate.longitude != 0) {
                        var formercoord = CLLocationCoordinate2D(latitude: self.prev.coordinate.latitude, longitude: self.prev.coordinate.longitude)
                        var former = CLLocation(coordinate: formercoord, altitude: self.prev.altitude, horizontalAccuracy: locationObj.horizontalAccuracy, verticalAccuracy: locationObj.verticalAccuracy, course: locationObj.course, speed: locationObj.speed, timestamp: locationObj.timestamp)
                        hdistance = locationObj.distanceFromLocation(former)
                        distance = sqrt(Double(pow(fabs(self.prev.altitude - alt), 2) + Double(pow(hdistance, 2))))
                        velocity = distance/(Double(updateTime) - Double(self.lastUpdateTime))
                    }
                
                    // Write to db.
                    // @todo use a timer to account for pauses.
                    var route = self.routeStore!.storeRoutePoint(self.routeId, date: updateTime, latitude: coord.latitude, longitude: coord.longitude, altitude: locationObj.altitude, velocity: velocity, distance_traveled: distance)
                    // Redraw the map
                    if let rv = self.routeView as? RouteView {
                        // @todo this is horrible for performance.
                        rv.summary!.updateRoute(self.routeId)
                        rv.displayLatest()
                        if let rav = self.routeAnalysisView as? RouteAnalysisView {
                            rav.updateLabels()
                        }
                    }
                    
                    self.lastUpdateTime = updateTime.advancedBy(Double(0.0))
                    self.prev = RunView.createLocationCopy(locationObj)
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
