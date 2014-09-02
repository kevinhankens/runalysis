//
//  RouteView.swift
//  JogLog
//
//  Created by Kevin Hankens on 8/18/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * Displays a route.
 */
class RouteView: UIView {
    
    // The core data storage of routes.
    var routeStore: RouteStore?
    
    // The currently viewed route ID.
    var routeId: NSNumber = 0
    
    // A list of points for the current route.
    var points: [RoutePoint] = [RoutePoint]()
    
    // The minimum x value of the route points.
    var gridMinX = 0.0
    
    // The maximum x value of the route points.
    var gridMaxX = 0.0
    
    // The minimum y value of the route points.
    var gridMinY = 0.0
    
    // The maximum y value of the route points.
    var gridMaxY = 0.0
    
    // The scale between the grid points and the canvas points.
    var gridRatio = 0.0
    
    var lowVelocity: Double = 0
    var highVelocity: Double = 0
    var averageVelocity: Double = 0
    
    /*!
     * Factory method to create a RouteView object.
     *
     * @param CGFloat x
     * @param CGFloat y
     * @param CGFloat width
     * @param CGFloat height
     * @param NSNumber routeId
     *
     * @return RouteView
     */
    class func createRouteView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, routeId: NSNumber, routeStore: RouteStore)->RouteView {
        
        let route = RouteView(frame: CGRectMake(x, y, width, width))
        
        route.routeStore = routeStore
        route.changeRoute(routeId)
        
        return route
    }
    
    /*!
     * Updates the currently viewed route.
     *
     * @param NSNumber id
     *
     * @return void
     */
    func changeRoute(id: NSNumber) {
        self.points.removeAll(keepCapacity: true)
        if id != self.routeId {
            self.routeId = id
        }
        let routePoints = self.routeStore!.getPointsForId(self.routeId)
        
        for p in routePoints {
            self.points.append(p)
        }
        
        self.determineGrid()
        self.determineVelocity()
        self.setNeedsDisplay()
    }
    
    func displayLatest() {
        self.determineGrid()
        self.determineVelocity()
        self.setNeedsDisplay()
    }
    
    func determineVelocity() {
        self.lowVelocity = 0
        self.highVelocity = 0
        self.averageVelocity = 0
        var count = 0
        var total: Double = 0
        for p in self.points {
            if p.velocity < self.lowVelocity {
                self.lowVelocity = p.velocity
            }
            else if p.velocity > self.highVelocity {
                self.highVelocity = p.velocity
            }
            total += Double(p.velocity)
            count++
        }
        if count > 0 {
            self.averageVelocity = total/Double(count)
        }
    }
    
    /*!
     * Determines the scale of the route in terms of the current canvas.
     *
     * @return void
     */
    func determineGrid() {
        if !self.points.isEmpty {
            self.gridMinX = self.points[0].longitude
            self.gridMaxX = self.points[0].longitude
            self.gridMinY = self.points[0].latitude
            self.gridMaxY = self.points[0].latitude
        }
        for p in self.points {
            if p.longitude > self.gridMaxX {
                self.gridMaxX = p.longitude
            }
            else if p.longitude < self.gridMinX {
                self.gridMinX = p.longitude
            }
            if p.latitude > self.gridMaxY {
                self.gridMaxY = p.latitude
            }
            else if p.latitude < self.gridMinY {
                self.gridMinY = p.latitude
            }
        }
        
        let diffX = fabs(self.gridMaxX - self.gridMinX)
        let diffY = fabs(self.gridMaxY - self.gridMinY)
        
        if (diffX > diffY) {
            if diffX > 0 {
                self.gridRatio = Double(self.frame.width) / diffX
            }
            else {
                self.gridRatio = 1
            }
        }
        else {
            if diffY > 0 {
                self.gridRatio = Double(self.frame.height) / diffY
            }
            else {
                self.gridRatio = 1
            }
        }
        //println("\(self.minX) \(self.maxX) \(self.minY) \(self.maxY)")
    }
    
    /*!
     * Overrides UIView::drawRect()
     *
     * Draws the currently viewed route and information.
     *
     * @param CGRect rect
     * 
     * @return void
     */
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextFillRect(context, self.bounds)
        CGContextSetLineWidth(context, 2.0)
        
        let velocityDiffBottom = self.averageVelocity - self.lowVelocity
        let velocityDiffTop = self.highVelocity - self.averageVelocity
        
        var px: CGFloat = 0.0
        var py: CGFloat = 0.0
        var cx: CGFloat = 0.0
        var cy: CGFloat = 0.0
        var ptime: NSNumber = 0
        var start = true
        for p in self.points {
            cx = CGFloat((p.longitude.doubleValue - self.gridMinX) * self.gridRatio)
            cy = CGFloat(self.frame.height) - CGFloat((p.latitude.doubleValue - self.gridMinY) * self.gridRatio)
            
            if start {
                start = false
            }
            else {
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, px, py);
                CGContextAddLineToPoint(context, cx, cy);
                if p.velocity < self.lowVelocity + velocityDiffBottom/2.5 {
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedOne().CGColor)
                }
                else if p.velocity < self.lowVelocity + ((velocityDiffBottom/2.5) * 2) {
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedTwo().CGColor)
                }
                else if p.velocity < self.lowVelocity + ((velocityDiffTop/2.5) * 2) {
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedThree().CGColor)
                }
                else if p.velocity < self.highVelocity - ((velocityDiffTop/2.5)) {
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedFour().CGColor)
                }
                else {
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedFive().CGColor)
                }
                CGContextStrokePath(context);
            }
            px = cx
            py = cy
            ptime = p.date
            //println("r: \(self.gridRatio)")
            //println("lat: \(p.latitude)")
            //println("lon: \(p.longitude)")
            //println("x: \(px)")
            //println("y: \(py)")
            //println("miny: \(self.bounds.minY)")
            //println("maxy: \(self.bounds.maxY)")
            //println("minx: \(self.bounds.minX)")
            //println("maxx: \(self.bounds.maxX)")
        }
    }

}
