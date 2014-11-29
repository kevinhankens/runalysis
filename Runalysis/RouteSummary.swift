//
//  RouteSummaryView.swift
//  Runalysis
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
    var mov_avg_low: CLLocationSpeed = Double(0)
    
    // The highest velocity reached.
    var velocity_high: CLLocationSpeed = Double(0)
    var mov_avg_high: CLLocationSpeed = Double(0)
    
    // The quantile for each bin.
    var velocity_step: CLLocationSpeed = Double(0)
    var mov_avg_step: CLLocationSpeed = Double(0)
    
    // The mean velocity over the course.
    var velocity_mean: CLLocationSpeed = Double(0)
    
    // The total distance traveled.
    var distance_total: CLLocationDistance = Double(0)
    
    // Tracks a distribution of velocities relative to the mean.
    var distribution = [0, 0, 0, 0, 0]
    
    var mov_avg_dist = [0, 0, 0, 0, 0]
    
    // Tracks the duration of the run.
    var duration: Double = Double(0)
    
    // Tracks the times for each mile run.
    var mileTimes: [Double] = []
    
    // How many miles per meter for conversions.
    let milesPerMeter = Double(0.00062137)

    /*!
     * Factory method to create a summary.
     *
     * @param NSNumber routeId
     * @param RouteStore routeStore
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
     *
     * @param NSNumber id
     */
    func updateRoute(id: NSNumber) {
        if id == self.routeId {
            // @todo != creates an error "ambiguous use of !="
        }
        else {
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
        let totalMiles = self.distance_total * self.milesPerMeter
        let rounded = round(totalMiles * 100)/100
        let miles = Int(rounded)
        let fraction = Int((rounded - Double(miles)) * 100)
        var fraction_string = "\(fraction)"
        if fraction < 10 {
            fraction_string = "0\(fraction)"
        }
        return "\(miles).\(fraction_string)"
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
        self.mov_avg_low = Double(0)
        self.mov_avg_high = Double(0)
        
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
        self.mileTimes.removeAll(keepCapacity: false)
        var mileCount = 0
        var mileTime = Double(0.0)
        var mileTimeTmp = Double(0.0)
        
        var movingAverage: [Double] = [0, 0, 0, 0, 0]
        var movingAverageTotal = Double(0.0)
        
        if self.points?.count > 0 {
            for p in self.points! {
                if let point = p as? Route {
                    if !started {
                        // skip the first one as 0 velocity skews the averages.
                        started = true
                        continue
                    }
                    
                    let testv: AnyObject? = point.valueForKey("velocity")
                    
                    if let v = testv as? NSNumber {
                        
                        // Determine the moving average by compiling a list
                        // of trailing values.
                        movingAverageTotal = 0.0
                        for (i, a) in enumerate(movingAverage) {
                            if i < movingAverage.count - 1 {
                                movingAverage[i] = movingAverage[i + 1]
                            }
                            else {
                                movingAverage[i] = point.velocity.doubleValue
                            }
                            movingAverageTotal += movingAverage[i]
                        }
                        
                        // Set the new velocity if the moving average array
                        // has enough values to be significant.
                        if count > movingAverage.count - 1 {
                            point.velocityMovingAvg = movingAverageTotal / Double(movingAverage.count)
                        }
                        else {
                            point.velocityMovingAvg = point.velocity
                        }
                        
                        if point.velocity.doubleValue > Double(0.0) {
                            if point.velocity.doubleValue < self.velocity_low || self.velocity_low == Double(0) {
                                // @todo low is always 0.
                                self.velocity_low = point.velocity.doubleValue
                            }
                            else if point.velocity.doubleValue > self.velocity_high {
                                self.velocity_high = point.velocity.doubleValue
                            }
                            if point.velocityMovingAvg.doubleValue < self.mov_avg_low || self.mov_avg_low == Double(0) {
                                self.mov_avg_low = point.velocityMovingAvg.doubleValue
                            }
                            else if point.velocityMovingAvg.doubleValue > self.mov_avg_high {
                                self.mov_avg_high = point.velocityMovingAvg.doubleValue
                            }
                            self.distance_total += Double(point.distance)
                            total += Double(point.velocity)
                            duration += Double(point.interval)
                            count++
                        }
                    }
                    
                    // Track the miles.
                    if Int(self.distance_total * self.milesPerMeter) > mileCount {
                        mileCount++
                        mileTimeTmp = duration - mileTime
                        mileTime = duration
                        self.mileTimes.append(mileTimeTmp)
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
        var tmp_mov = [0,0,0,0,0]
        
        let velocityDiff = self.velocity_high - self.velocity_low
        self.velocity_step = velocityDiff/5
        
        let velocityDiffMov = self.mov_avg_high - self.mov_avg_low
        self.mov_avg_step = velocityDiffMov/5
        
        if self.points?.count > 0 {
            for p: AnyObject in self.points! {
                if let point = p as? Route {
                    // This is a little overkill, but the simulator occasionally
                    // fails leaving an invalid point in the db due to a null value
                    // for the velocity column. Strange because it's got a default
                    // value of 0. This is the only way I've found to prevent crashing.
                    let testv: AnyObject? = point.valueForKey("velocity")
                    
                    if let v = testv as? NSNumber {
                        rel = self.getRelativeVelocity(point.velocity, low: self.velocity_low, step: self.velocity_step).integerValue
                        point.relativeVelocity = rel
                        tmp[rel]++
                        rel = self.getRelativeVelocity(point.velocityMovingAvg, low: self.mov_avg_low, step: self.mov_avg_step).integerValue
                        point.relVelMovingAvg = rel
                        tmp_mov[rel]++
                    }
                }
            }
        }
        
        var i = 0
        for i = 0; i < 5; i++ {
            self.distribution[i] = tmp[i]
            self.mov_avg_dist[i] = tmp_mov[i]
        }
    }
    
    /*!
     * Gets the relative velocity of a point compared to the high, low and average.
     *
     * @return NSNumber
     */
    func getRelativeVelocity(velocity: NSNumber, low: CLLocationSpeed, step: CLLocationSpeed)->NSNumber {
        var rel = 0
        
        if velocity.doubleValue < low + step {
            rel = 0
        }
        else if velocity.doubleValue < low + (step * 2) {
            rel = 1
        }
        else if velocity.doubleValue < low + (step * 3) {
            rel = 2
        }
        else if velocity.doubleValue < low + (step * 4) {
            rel = 3
        }
        else {
            rel = 4
        }
        
        return rel
    }

}
