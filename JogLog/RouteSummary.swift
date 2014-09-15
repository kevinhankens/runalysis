//
//  RouteSummaryView.swift
//  JogLog
//
//  Created by Kevin Hankens on 9/3/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * Provides a summary of a list of Route objects.
 */
class RouteSummary: NSObject {
    
    // Tracks the route store.
    var routeStore: RouteStore?
    
    // Tracks the current route ID.
    var routeId: NSNumber = 0
    
    // Tracks a list of route points.
    var points: [AnyObject]?
    
    // The lowest velocity, currently 0.
    var velocity_low: CLLocationSpeed = Double(0)
    
    // The highest velocity reached.
    var velocity_high: CLLocationSpeed = Double(0)
    
    // The mean velocity over the course.
    var velocity_mean: CLLocationSpeed = Double(0)
    
    // The total distance traveled.
    var distance_total: CLLocationDistance = Double(0)
    
    // Tracks a distribution of velocities relative to the mean.
    var distribution = [0, 0, 0, 0, 0]
    
    // Tracks the duration of the run.
    var duration: Double = Double(0)

    /*!
     * Factory method to create a summary.
     *
     * @return RouteSummary
     */
    class func createRouteSummary(routeId: NSNumber, routeStore: RouteStore)->RouteSummary {
            
        let rsv = RouteSummary()
        
        rsv.routeStore = routeStore
        
        rsv.updateRoute(routeId)
            
        return rsv
    }

    /*!
     * Upstes the summary to a new set of points.
     */
    func updateRoute(id: NSNumber) {
        if id != self.routeId {
            self.routeId = id
        }
        // @todo can we skip this if the screen is locked?
        self.points = self.routeStore!.getPointsForId(self.routeId)
        
        self.calculateSummary()
    }
    
    /*!
     * Gets a label for the total mileage with the pace.
     *
     * @return String
     */
    func getTotalAndPace()->String {
        return "\(self.totalInMiles())mi @\(self.avgVelocityInMinutesPerMile())"
    }
    
    /*!
     * Gets the total in miles.
     *
     * @return String
     */
    func totalInMiles()->String {
        let totalMiles = self.distance_total * Double(0.00062137)
        let rounded = round(totalMiles * 100)/100
        let miles = Int(rounded)
        let fraction = Int((rounded - Double(miles)) * 100)
        var fracton_string = "\(fraction)"
        if fraction < 10 {
            fracton_string = "0\(fraction)"
        }
        return "\(miles).\(fraction)"
    }
    
    /*!
     * Gets the average velocity in miles per hour.
     *
     * @return Double
     */
    func avgVelocityInMilesPerHour()->Double {
        let milesPerSecond = self.velocity_mean * Double(0.00062137)
        return milesPerSecond * Double(3600)
    }
    
    /*!
     * Gets a label for the average pace in minutes per mile.
     *
     * @return String
     */
    func avgVelocityInMinutesPerMile()->String {
        let milesperminute = self.avgVelocityInMilesPerHour()/Double(60)
        if milesperminute > 0 {
            let minutespermile = Double(1)/milesperminute
            let minutes = Int(minutespermile)
            let seconds = Int(round((minutespermile - Double(minutes)) * 60))
            var seconds_string = "\(String(seconds))"
            if seconds < Int(10) {
                seconds_string = "0\(String(seconds))"
            }
            return "\(String(minutes)):\(seconds_string)"
        }
        return "0:00"
    }
    
    /*!
     * Calculates the averages and totals for the set of points.
     */
    func calculateSummary() {
        self.velocity_low = Double(0)
        self.velocity_high = Double(0)
        self.velocity_mean = Double(0)
        self.distance_total = Double(0)
        
        self.calculateVelocity()
        self.calculateDistribution()
        //println("Distribution: \(self.distribution)");
        //println("Low: \(self.velocity_low)");
        //println("High: \(self.velocity_high)");
        //println("Mean: \(self.velocity_mean)");
        //println("Dist: \(self.distance_total)");
    }
    
    /*!
     * Calculates the average velocity and the total distance.
     */
    func calculateVelocity() {
        var count = 0
        var total = Double(0)
        var started = false
        var duration = Double(0)
        
        if self.points?.count > 0 {
            for p in self.points! {
                if let point = p as? Route {
                    if !started {
                        // skip the first one as 0 velocity skews the averages.
                        started = true
                        continue
                    }
                    
                    if point.velocity > Double(0.0) {
                        if point.velocity < self.velocity_low {
                            // @todo low is always 0.
                            self.velocity_low = point.velocity
                        }
                        else if point.velocity > self.velocity_high {
                            self.velocity_high = point.velocity
                        }
                        self.distance_total += Double(point.distance)
                        total += Double(point.velocity)
                        duration += Double(point.interval)
                        count++
                    }
                }
            }
        }
        if count > 0 {
            self.velocity_mean = total/Double(count)
            self.duration = duration
        }
    }
    
    /*!
     * Calculates the distribution of velocities.
     */
    func calculateDistribution() {
        var rel = 0
        // For some reason trying to adjust self.distribution is very expensive. So do it in a local var and update once at the end.
        var tmp = [0,0,0,0,0]
        
        if self.points?.count > 0 {
            for p in self.points! {
                if let point = p as? Route {
                    rel = self.getRelativeVelocity(point)
                    point.relativeVelocity = rel
                    tmp[rel]++
                }
            }
        }
        
        var i = 0
        for i = 0; i < 5; i++ {
            self.distribution[i] = tmp[i]
        }
    }
    
    /*!
     * Gets the relative velocity of a point compared to the high, low and average.
     *
     * @param Route point
     *
     * @return NSNumber
     */
    func getRelativeVelocity(point: Route)->NSNumber {
        let velocityDiffBottom = self.velocity_mean - self.velocity_low
        let velocityDiffTop = self.velocity_high - self.velocity_mean
        var rel = 0
        
        if point.velocity < self.velocity_low + velocityDiffBottom/2.5 {
            rel = 0
        }
        else if point.velocity < self.velocity_low + ((velocityDiffBottom/2.5) * 2) {
            rel = 1
        }
        else if point.velocity < self.velocity_high - ((velocityDiffTop/2.5) * 2) {
            rel = 2
        }
        else if point.velocity < self.velocity_high - ((velocityDiffTop/2.5)) {
            rel = 3
        }
        else {
            rel = 4
        }
        
        return rel
    }

}