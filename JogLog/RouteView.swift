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
    
    // Provides a summary of the array of RoutePoint objects.
    var summary: RouteSummary?
    
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
    
    var distLabel: UILabel?
    
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
        route.summary = RouteSummary.createRouteSummary(routeId, routeStore: routeStore)
        
        route.routeStore = routeStore
        route.changeRoute(routeId)
        
        var ypos = route.frame.height
        
        let distLabel = UILabel(frame: CGRectMake(10, ypos, route.bounds.width, 20))
        distLabel.text = route.summary!.getTotalAndPace()
        distLabel.textColor = GlobalTheme.getNormalTextColor()
        route.distLabel = distLabel
        route.addSubview(distLabel)
        
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
        if id != self.routeId {
            self.routeId = id
        }
        
        self.displayLatest()
    }
    
    /*!
     *
     */
    func displayLatest() {
        self.summary?.updateRoute(self.routeId)
        if let dl = self.distLabel as? UILabel {
            dl.text = self.summary!.getTotalAndPace()
        }
        self.determineGrid()
        self.setNeedsDisplay()
    }
    
    /*!
     * Determines the scale of the route in terms of the current canvas.
     *
     * @return void
     */
    func determineGrid() {
        if self.summary!.points?.count > 0 {
            if let zp = self.summary!.points![0] as? Route {
                self.gridMinX = zp.longitude
                self.gridMaxX = zp.longitude
                self.gridMinY = zp.latitude
                self.gridMaxY = zp.latitude
            }
            for point in self.summary!.points! {
                if let p = point as? Route {
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
        var mileCounter = 0
        var mileTest = 0
        var total = Double(0)
        
        let context = UIGraphicsGetCurrentContext()
        CGContextFillRect(context, self.bounds)
        
        var px: CGFloat = 0.0
        var py: CGFloat = 0.0
        var cx: CGFloat = 0.0
        var cy: CGFloat = 0.0
        var ptime: NSNumber = 0
        var start = true
        if self.summary!.points?.count > 0 {
        for point in self.summary!.points! {
            if let p = point as? Route {
            cx = CGFloat((p.longitude.doubleValue - self.gridMinX) * self.gridRatio)
            cy = CGFloat(self.frame.height) - CGFloat((p.latitude.doubleValue - self.gridMinY) * self.gridRatio)
            
            if start {
                start = false
            }
            else {
                switch p.relativeVelocity {
                case 0:
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedOne().CGColor)
                case 1:
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedTwo().CGColor)
                case 2:
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedThree().CGColor)
                case 3:
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedFour().CGColor)
                case 4:
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedFive().CGColor)
                default:
                    CGContextSetStrokeColorWithColor(context, GlobalTheme.getSpeedOne().CGColor)
                }
                
                CGContextSetLineWidth(context, 4.0)
                CGContextBeginPath(context);
                CGContextMoveToPoint(context, px, py);
                CGContextAddLineToPoint(context, cx, cy);
                CGContextStrokePath(context);
                
                CGContextSetLineWidth(context, 1.0)
                var center = CGPointMake(cx, cy)
                CGContextAddArc(context, center.x, center.y, CGFloat(2.0), CGFloat(0), CGFloat(2*M_PI), Int32(0))
                CGContextStrokePath(context);
                
                // Draw a mile marker
                total += p.distance.doubleValue * Double(0.00062137)
                mileTest = Int(total)
                if mileTest > mileCounter {
                    mileCounter = mileTest
                    var center = CGPointMake(cx, cy)
                    CGContextAddArc(context, center.x, center.y, CGFloat(12.0), CGFloat(0), CGFloat(2*M_PI), Int32(0))
                    CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
                    CGContextStrokePath(context);
                }
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
    }

}
