//
//  RunView.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class RunView: UIView, CLLocationManagerDelegate {
    
    // Tracks the Core Location Manager.
    var locationManager: CLLocationManager?
    
    // Tracks the route storage engine.
    var routeStore: RouteStore?
    
    // Tracks the current route ID.
    let routeId = Int(NSDate().timeIntervalSince1970)
    
    // Tracks the previous location.
    var prev = CLLocation()
    
    // Tracks the last time the run was updated.
    var lastUpdateTime: NSDate = NSDate.date()
    
    // How often to update during a run.
    let updateInterval: NSTimeInterval = 4.0
    
    var lastDrawTime: NSDate = NSDate.date()
    
    let redrawInterval: NSTimeInterval = 8.0
    
    // Whether or not we are currently recording.
    var recording: Bool = false
    
    // Tracks whether there was a CLLocationManager failure.
    var failed: Bool = false
    
    // Tracks the RouteView object.
    var routeView: RouteView?
    
    // Tracks the RouteAnalysisView object.
    var routeAnalysisView: RouteAnalysisView?
    
    // Tracks the timer which is used as a stopwatch.
    var stopwatch: NSTimer?
    
    // Tracks the duration of the entire run.
    var duration: NSTimeInterval = NSDate().timeIntervalSinceNow
    
    var accuracy: UILabel?
    
    /*!
     * Factory method to create a RunView.
     *
     * @param CGFloat x
     * @param CGFloat y
     * @param CGFloat cellHeight
     * @param CGFloat cellWidth
     * @param RouteStore routeStore
     * @param CLLocationManager locationManager
     * @param TouteSummary routeSummary
     *
     * @return RunView
     */
    class func createRunView(x: CGFloat, y: CGFloat, cellHeight: CGFloat, cellWidth:
        CGFloat, routeStore: RouteStore, locationManager: CLLocationManager, routeSummary: RouteSummary)->RunView {
            
        let runView = RunView(frame: CGRect(x: x, y: y, width: cellWidth, height: cellHeight))
            
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
        record.frame = CGRectMake(10, ypos, runView.bounds.width - 20, 45.00)
        record.setTitle("Start", forState: UIControlState.Normal)
        record.setTitleColor(GlobalTheme.getStartTextColor(), forState: UIControlState.Normal)
        record.backgroundColor = GlobalTheme.getStartBgColor()
        record.titleLabel?.font = UIFont.systemFontOfSize(45.0)
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
        let rav = RouteAnalysisView.createRouteAnalysisView(80.0, cellWidth: runView.bounds.width, x: 0, y: ypos, routeSummary: routeSummary)
        runView.addSubview(rav)
        runView.routeAnalysisView = rav
        rav.userInteractionEnabled = false
            
        ypos = ypos + rav.frame.height + 10
            
        record.frame.origin.y = routeView.frame.minY + (routeView.frame.height/2)
            
        let signal = UILabel(frame: CGRectMake(10, record.frame.minY - 25, runView.frame.width - 20, 25))
        signal.text = "Retrieving Accuracy"
        signal.textColor = GlobalTheme.getInvertedTextColor()
        signal.backgroundColor = GlobalTheme.getAccuracyFairColor()
        signal.font = GlobalTheme.getNormalFont()
        signal.textAlignment = NSTextAlignment.Center
        runView.accuracy = signal
        runView.addSubview(signal)
            
        runView.bringSubviewToFront(record)
            
        runView.stopwatch = NSTimer.scheduledTimerWithTimeInterval(0.1, target: runView, selector: Selector("updateStopwatch"), userInfo: nil, repeats: true)
            
        let f = CGRectMake(x, y, runView.frame.width, ypos)
        runView.frame = f
          
        return runView
    }
    
    /*!
     * NSTimer callback to display the chronograph.
     */
    func updateStopwatch() {
        if self.recording {
            if let rav = self.routeAnalysisView? {
                // How long since we last updated.
                var interval = fabs(self.lastUpdateTime.timeIntervalSinceNow)
                // Sets the overall duration in the route analysis view.
                rav.updateDuration(self.duration + interval)
            }
        }
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
        if self.failed {
            return
        }
        if self.recording {
            self.recording = false
            sender.setTitle("Resume", forState: UIControlState.Normal)
            sender.setTitleColor(GlobalTheme.getStartTextColor(), forState: UIControlState.Normal)
            sender.backgroundColor = GlobalTheme.getStartBgColor()
            if (self.locationManager != nil) {
                if let loc = self.locationManager? {
                    // @todo protect unwrapping nil.
                    let locationObj = RunView.createLocationCopy(loc.location)
                    let interval = fabs(self.lastUpdateTime.timeIntervalSinceNow)
                    self.storePoint(locationObj, interval: interval)
                }
            }
            else {
                self.stopRecordingAndDisplayLocationAlert()
            }
        }
        else {
            self.recording = true
            sender.setTitle("Pause", forState: UIControlState.Normal)
            sender.setTitleColor(GlobalTheme.getStopTextColor(), forState: UIControlState.Normal)
            sender.backgroundColor = GlobalTheme.getStopBgColor()
            self.lastUpdateTime = NSDate.date()
            if (self.locationManager != nil) {
                if let loc = self.locationManager? {
                    // In the simulator the location object occasionally fails.
                    // @todo disable button.
                    self.prev = RunView.createLocationCopy(loc.location)
                    self.storePoint(self.prev, interval: 0.0)
                }
            }
            else {
                self.stopRecordingAndDisplayLocationAlert()
            }
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
    
    func setAccuracyLabel(accuracy: CLLocationAccuracy) {
        if let a = self.accuracy? {
            if accuracy < Double(20) {
                a.backgroundColor = GlobalTheme.getAccuracyGoodColor()
                a.text = "Accuracy: Good (\(accuracy))"
            }
            else if accuracy < Double(50) {
                a.backgroundColor = GlobalTheme.getAccuracyFairColor()
                a.text = "Accuracy: Fair (\(accuracy))"
            }
            else {
                a.backgroundColor = GlobalTheme.getAccuracyPoorColor()
                a.text = "Accuracy: Poor (\(accuracy))"
            }
        }
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
        var interval: NSTimeInterval = 0.0
        
        interval = fabs(self.lastUpdateTime.timeIntervalSinceDate(locationObj.timestamp))
        if (interval > self.updateInterval) {
            
            setAccuracyLabel(locationObj.horizontalAccuracy)
            
            if self.recording {
                if (self.prev.coordinate.latitude != coord.latitude || self.prev.coordinate.longitude != coord.longitude) {
                    self.storePoint(locationObj, interval: interval)
                }
            }
        }
    }
    
    /*!
     * Stores a location point in the database.
     *
     * @param CLLocation location
     * @param NSTimeInterval interval
     */
    func storePoint(location: CLLocation, interval: NSTimeInterval) {
        if CLLocationCoordinate2DIsValid(location.coordinate) {
            var coord = location.coordinate
            var alt = location.altitude
            var hdistance: Double = 0
            var distance: Double = 0
            var velocity: Double = 0
 
            // Velocity calculation
            if (self.prev.coordinate.latitude != 0 && self.prev.coordinate.longitude != 0) {
                var formercoord = CLLocationCoordinate2D(latitude: self.prev.coordinate.latitude, longitude: self.prev.coordinate.longitude)
                var former = CLLocation(coordinate: formercoord, altitude: self.prev.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, speed: location.speed, timestamp: location.timestamp)
                hdistance = location.distanceFromLocation(former)
                distance = sqrt(Double(pow(fabs(self.prev.altitude - alt), 2) + Double(pow(hdistance, 2))))
                velocity = distance/interval
            }
        
            // Steps coming soon.
            let steps = 0
    
            // Write to db.
            var route = self.routeStore!.storeRoutePoint(self.routeId, date: location.timestamp.timeIntervalSince1970, latitude: coord.latitude, longitude: coord.longitude, altitude: location.altitude, velocity: velocity, distance_traveled: distance, interval: interval, steps: steps)
            
            // Redraw the map
            if let rv = self.routeView? {
                var tc = self.lastDrawTime.dateByAddingTimeInterval(self.redrawInterval)
                if tc.timeIntervalSinceNow < 0.0 {
                    if let summary = rv.summary {
                        summary.points?.append(route)
                        summary.calculateSummary()
                    // @todo this is horrible for performance.
                    //rv.summary!.updateRoute(self.routeId)
                    rv.displayLatest()
                    if let rav = self.routeAnalysisView? {
                        rav.updateLabels()
                    }
                    self.lastDrawTime = tc
                    }
                }
            }
            
            self.duration += fabs(self.lastUpdateTime.timeIntervalSinceNow)
            self.lastUpdateTime = location.timestamp.dateByAddingTimeInterval(0.0)
            self.prev = RunView.createLocationCopy(location)
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
        if (error != nil) {
            if (self.failed == false) {
                self.failed = true
                self.stopRecordingAndDisplayLocationAlert()
                print(error)
            }
        }
    }
    
    func stopRecordingAndDisplayLocationAlert() {
        self.recording = false
        self.failed = true
        let alert = UIAlertView(title: "Location Error", message: "Your location is unavailable, possibly due to your privacy settings. Please check your system settings under Privacy > Location Services.", delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
    
}
