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
    var distribution = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    var mov_avg_dist = [0, 0, 0, 0, 0, 0, 0, 0, 0]
    
    var animation_length: Int = 0
    
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
        var distanceTotal = Double(0.0)
        
        var movingAverage: [Double] = [0, 0, 0, 0, 0]
        var movingAverageTotal = Double(0.0)
        
        if self.points?.count > 0 {
        
            var velocityRange = [Double](count: self.points!.count, repeatedValue: 0.0)
            
            // Find outliers.
            var i = 0
            for p in self.points! {
                if let point = p as? Route {
                    // Track the raw double value to speed up drawing.
                    point.latitude_raw = point.latitude.doubleValue
                    point.longitude_raw = point.longitude.doubleValue
                    point.altitude_raw = point.altitude.doubleValue
                    
                    // Track the range of velocity points.
                    point.velocity_raw = point.velocity.doubleValue
                    velocityRange[i] = point.velocity_raw
                }
                i++
            }
            
            // Determine inner fences.
            velocityRange.sort { $0 < $1 }
            let q25 = locateQuantile(0.25, values: velocityRange)
            let q75 = locateQuantile(0.75, values: velocityRange)
            let qr = 1.5 * (q75 - q25)
            let bl = q25 - qr
            let bu = q75 + qr
            
            var vlow = 0.0
            var vhigh = 0.0
            var malow = 0.0
            var mahigh = 0.0
            
            var movingAveragePos = 0
            
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
                        movingAverageTotal -= movingAverage[movingAveragePos]
                        movingAverageTotal += point.velocity_raw
                        movingAverage[movingAveragePos] = point.velocity_raw
                        movingAveragePos++
                        if movingAveragePos > 4 {
                            movingAveragePos = 0
                        }
                        
                        // Set the new velocity if the moving average array
                        // has enough values to be significant.
                        if count > 4 {
                            point.velocityMovingAvg = movingAverageTotal / Double(movingAverage.count)
                        }
                        else {
                            point.velocityMovingAvg = point.velocity_raw
                        }
                        
                        if point.velocity_raw > Double(0.0) {
                            // Check for outliers.
                            if point.velocity_raw > bu {
                                point.velocity = NSNumber(double: bu)
                                point.velocity_raw = bu
                            }
                            
                            if point.velocity_raw < vlow || vlow == Double(0) {
                                // @todo low is always 0.
                                vlow = point.velocity_raw
                            }
                            else if point.velocity_raw > vhigh {
                                vhigh = point.velocity_raw
                            }
                            if point.velocityMovingAvg < malow || malow == Double(0) {
                                malow = point.velocityMovingAvg
                            }
                            else if point.velocityMovingAvg > mahigh {
                                mahigh = point.velocityMovingAvg
                            }
                            distanceTotal += Double(point.distance)
                            total += Double(point.velocity)
                            duration += Double(point.interval)
                            count++
                        }
                    }
                    
                    
                    // Track the miles.
                    if Int(distanceTotal * self.milesPerMeter) > mileCount {
                        mileCount++
                        mileTimeTmp = duration - mileTime
                        mileTime = duration
                        self.mileTimes.append(mileTimeTmp)
                    }
                }
            }
            self.distance_total = distanceTotal
            self.velocity_low = vlow
            self.velocity_high = vhigh
            self.mov_avg_low = malow
            self.mov_avg_high = mahigh
        }
        if count > 0 {
            self.velocity_mean = total/Double(count)
            self.duration = duration
        }
    }
    
    /*!
     * Locates the quantile given an array of sorted values.
     *
     * @param quantile
     * @param values
     *
     * @return Double
     */
    func locateQuantile(quantile: Double, values: [Double])->Double {
        let length = values.count
        let index = quantile * Double(length-1)
        let boundary = Int(index)
        let delta = index - Double(boundary)
        
        if length == 0 {
            return 0.0
        } else if boundary == length-1 {
            return values[boundary]
        } else {
            return (1-delta)*values[boundary] + delta*values[boundary+1]
        }
    }
    
    /*!
     * Calculates the distribution of velocities.
     */
    func calculateDistribution() {
        var rel = 0
        // For some reason trying to adjust self.distribution is very expensive. So do it in a local var and update once at the end.
        var tmp = [0,0,0,0,0,0,0,0,0]
        var tmp_mov = [0,0,0,0,0,0,0,0,0]
        
        let velocityDiff = self.velocity_high - self.velocity_low
        self.velocity_step = velocityDiff/Double(tmp.count)
        
        let velocityDiffMov = self.mov_avg_high - self.mov_avg_low
        self.mov_avg_step = velocityDiffMov/Double(tmp_mov.count)
        
        if self.points?.count > 0 {
            for p: AnyObject in self.points! {
                if let point = p as? Route {
                    // This is a little overkill, but the simulator occasionally
                    // fails leaving an invalid point in the db due to a null value
                    // for the velocity column. Strange because it's got a default
                    // value of 0. This is the only way I've found to prevent crashing.
                    let testv: AnyObject? = point.valueForKey("velocity")
                    
                    if let v = testv as? NSNumber {
                        rel = self.getRelativeVelocity(point.velocity_raw, low: self.velocity_low, step: self.velocity_step)
                        point.relativeVelocity = rel
                        tmp[rel]++
                        rel = self.getRelativeVelocity(point.velocityMovingAvg, low: self.velocity_low, step: self.velocity_step)
                        point.relVelMovingAvg = rel
                        tmp_mov[rel]++
                    }
                }
            }
        }
        
        var i = 0
        for i = 0; i < tmp.count; i++ {
            self.distribution[i] = tmp[i]
            self.mov_avg_dist[i] = tmp_mov[i]
        }
    }
    
    /*!
     * Gets the relative velocity of a point compared to the high, low and average.
     *
     * @return NSNumber
     */
    func getRelativeVelocity(velocity: Double, low: CLLocationSpeed, step: CLLocationSpeed)->Int {
        var rel = 0
        
        for var i = 0; i < self.distribution.count; i++ {
            if velocity < low + (step * Double((i + 1))) {
                rel = i
                break
            }
        }
       
        return rel
    }
    
}
