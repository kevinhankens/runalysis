//
//  RouteView.swift
//  Runalysis
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
    
    // The width of the course drawing.
    let lineWidth = CGFloat(5.0)
    
    /*!
     * Factory method to create a RouteView object.
     *
     * @param CGFloat x
     * @param CGFloat y
     * @param CGFloat width
     * @param CGFloat height
     * @param NSNumber routeId
     * @param RouteStore routeStore
     * @param RouteSummary routeSummary
     *
     * @return RouteView
     */
    class func createRouteView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, routeId: NSNumber, routeStore: RouteStore, routeSummary: RouteSummary)->RouteView {
        
        let route = RouteView(frame: CGRectMake(x, y, width, width))
        route.summary = routeSummary
        route.routeStore = routeStore
        route.updateRoute()
        
        route.sizeToFit()
       
        return route
    }
    
    /*!
     * Updates the currently viewed route.
     *
     * @return void
     */
    func updateRoute() {
        self.displayLatest()
    }
    
    /*!
     *
     */
    func displayLatest() {
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
                self.gridMinX = zp.longitude_raw
                self.gridMaxX = zp.longitude_raw
                self.gridMinY = zp.latitude_raw
                self.gridMaxY = zp.latitude_raw
            }
            for point in self.summary!.points! {
                if let p = point as? Route {
                    if p.longitude_raw > self.gridMaxX {
                        self.gridMaxX = p.longitude_raw
                    }
                    else if p.longitude_raw < self.gridMinX {
                        self.gridMinX = p.longitude_raw
                    }
                    if p.latitude_raw > self.gridMaxY {
                        self.gridMaxY = p.latitude_raw
                    }
                    else if p.latitude_raw < self.gridMinY {
                        self.gridMinY = p.latitude_raw
                    }
                }
            }
        }
        
        let diffX = fabs(self.gridMaxX - self.gridMinX)
        let diffY = fabs(self.gridMaxY - self.gridMinY)
        
        if (diffX > diffY) {
            if diffX > 0 {
                self.gridRatio = Double(self.bounds.width - 20) / diffX
            }
            else {
                self.gridRatio = 1
            }
        }
        else {
            if diffY > 0 {
                self.gridRatio = Double(self.bounds.width - 20) / diffY
            }
            else {
                self.gridRatio = 1
            }
        }
        //println("\(self.bounds)")
        //println("\(self.gridMinX) \(self.gridMaxX) \(self.gridMinY) \(self.gridMaxY)")
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
        var unitCounter = 0
        var unitTest = 0
        var total = Double(0)
        
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, GlobalTheme.getBackgroundColor().CGColor);
        CGContextFillRect(ctx, self.bounds)
        
        var px: CGFloat = 0.0
        var py: CGFloat = 0.0
        var ppx: CGFloat = 0.0
        var ppy: CGFloat = 0.0
        var cx: CGFloat = 0.0
        var cy: CGFloat = 0.0
        var dx: CGFloat = 0.0
        var dy: CGFloat = 0.0
        var wx: CGFloat = 0.0
        var wy: CGFloat = 0.0
        var bx: CGFloat = 0.0
        var by: CGFloat = 0.0
        var dhyp: CGFloat = 0.0
        var dratio: CGFloat = 0.0
        
        var q: Int = 0
        var d: CGFloat = 0.0
        //var ptime: NSNumber = 0.0
        var start = true
        var speedColor: CGColor
        var animation_steps = 0
        if self.summary!.points?.count > 0 {
            for point in self.summary!.points! {
                if let p = point as? Route {
                    cx = CGFloat((p.longitude_raw - self.gridMinX) * self.gridRatio) + 10.0
                    cy = CGFloat(self.frame.height) - CGFloat((p.latitude_raw - self.gridMinY) * self.gridRatio) - 10.0
                    
                    animation_steps++
                    if animation_steps > self.summary!.animation_length {
                        break
                    }
                    
                    if start || p.velocity.doubleValue > 0.0 {
                        
                        if start {
                            start = false
                        }
                        else {
                            speedColor = GlobalTheme.getSpeedColor(p.relVelMovingAvg, setAlpha: 1.0).CGColor
                            
                            CGContextSetStrokeColorWithColor(ctx, speedColor)
                            
                            // Calculate the change in x/y.
                            dx = fabs(cx - px)
                            dy = fabs(cy - py)
                            
                            // Find the ratio of change vs perpendicular line
                            // to create a box.
                            dhyp = sqrt(pow(dx, 2) + pow(dy, 2))
                            dratio = dhyp/self.lineWidth
                            
                            if dratio == 0.0 {
                                wx = 0.0
                                wy = 0.0
                            }
                            else {
                                wx = dy/dratio
                                wy = dx/dratio
                            }
                            
                            // Back everything up a tiny amount so that we
                            // don't have lines separating the boxes
                            bx = 0.1 * wx
                            by = 0.1 * wy
                            
                            if cx > px && cy > py {
                                // Moving SE
                                q = 0
                                wx *= -1
                                px -= by
                                py -= bx
                            }
                            else if cx > px && cy < py {
                                // Moving NE
                                q = 1
                                px -= by
                                py += bx
                            }
                            else if cx < px && cy < py {
                                // Moving NW
                                q = 2
                                wy *= -1
                                px += by
                                py += bx
                            }
                            else {  // cx < px && cy > py
                                // Moving SW or not moving
                                q = 3
                                wx *= -1
                                wy *= -1
                                px += by
                                py -= bx
                            }
                            
                            // Create a box path.
                            var path = CGPathCreateMutable();
                            CGPathMoveToPoint(path, nil, px, py)
                            CGPathAddLineToPoint(path, nil, cx, cy)
                            CGPathAddLineToPoint(path, nil, cx + wx, cy + wy)
                            CGPathAddLineToPoint(path, nil, px + wx, py + wy)
                            CGPathAddLineToPoint(path, nil, ppx, ppy)
                            CGPathAddLineToPoint(path, nil, px, py)
                            
                            CGContextSetFillColorWithColor(ctx, speedColor)
                            CGContextAddPath(ctx, path)
                            CGContextDrawPath(ctx, kCGPathFill)
                            
                            // Draw a unit (mi/km) marker
                            total += RunalysisUnits.convertMetersToUnits(p.distance.doubleValue)
                            unitTest = Int(total)
                            if unitTest > unitCounter {
                                unitCounter = unitTest
                                var center = CGPointMake(cx, cy)
                                CGContextSetLineWidth(ctx, 1.0)
                                CGContextAddArc(ctx, center.x, center.y, CGFloat(12.0), CGFloat(0), CGFloat(2*M_PI), Int32(0))
                                CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor().CGColor)
                                CGContextStrokePath(ctx);
                            }
                        }
                    }
                    px = cx
                    py = cy
                    ppx = cx + wx
                    ppy = cy + wy
                }
            }
        }
    }
}
