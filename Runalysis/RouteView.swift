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
                self.gridMinX = zp.longitude.doubleValue
                self.gridMaxX = zp.longitude.doubleValue
                self.gridMinY = zp.latitude.doubleValue
                self.gridMaxY = zp.latitude.doubleValue
            }
            for point in self.summary!.points! {
                if let p = point as? Route {
                    if p.longitude.doubleValue > self.gridMaxX {
                        self.gridMaxX = p.longitude.doubleValue
                    }
                    else if p.longitude.doubleValue < self.gridMinX {
                        self.gridMinX = p.longitude.doubleValue
                    }
                    if p.latitude.doubleValue > self.gridMaxY {
                        self.gridMaxY = p.latitude.doubleValue
                    }
                    else if p.latitude.doubleValue < self.gridMinY {
                        self.gridMinY = p.latitude.doubleValue
                    }
                }
            }
        }
        
        let diffX = fabs(self.gridMaxX - self.gridMinX)
        let diffY = fabs(self.gridMaxY - self.gridMinY)
        
        if (diffX > diffY) {
            if diffX > 0 {
                self.gridRatio = Double(self.frame.width - 20) / diffX
            }
            else {
                self.gridRatio = 1
            }
        }
        else {
            if diffY > 0 {
                self.gridRatio = Double(self.frame.height - 20) / diffY
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
    //override func drawRect(rect: CGRect) {
    override func drawLayer(layer: CALayer!, inContext ctx: CGContext!) {
        var mileCounter = 0
        var mileTest = 0
        var total = Double(0)
        
        //let context = UIGraphicsGetCurrentContext()
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
        var dhyp: CGFloat = 0.0
        var dratio: CGFloat = 0.0
        
        var q: Int = 0
        var d: CGFloat = 0.0
        //var ptime: NSNumber = 0.0
        var start = true
        var speedColor: CGColor
        if self.summary!.points?.count > 0 {
            for point in self.summary!.points! {
                if let p = point as? Route {
                    cx = CGFloat((p.longitude.doubleValue - self.gridMinX) * self.gridRatio) + 10.0
                    cy = CGFloat(self.frame.height) - CGFloat((p.latitude.doubleValue - self.gridMinY) * self.gridRatio) - 10.0
                    
                    if start || p.velocity.doubleValue > 0.0 {
                        
                        if start {
                            //var center = CGPointMake(cx, cy)
                            //CGContextAddArc(context, center.x, center.y, CGFloat(6.0), CGFloat(0), CGFloat(2*M_PI), Int32(0))
                            //CGContextSetFillColorWithColor(context, GlobalTheme.getSpeedOne().CGColor);
                            //CGContextFillPath(context);
                            start = false
                        }
                        else {
                            speedColor = GlobalTheme.getSpeedColor(p.relVelMovingAvg.integerValue, setAlpha: 1.0).CGColor
                            
                            CGContextSetStrokeColorWithColor(ctx, speedColor)
                            
                            dx = fabs(cx - px)
                            dy = fabs(cy - py)
                            
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
                            
                            if cx > px && cy > py {
                                // Moving SE
                                q = 0
                                wx *= -1
                            }
                            else if cx > px && cy < py {
                                // Moving NE
                                q = 1
                            }
                            else if cx < px && cy < py {
                                // Moving NW
                                q = 2
                                wy *= -1
                            }
                            else {  // cx < px && cy > py
                                // Moving SW or not moving
                                q = 3
                                wx *= -1
                                wy *= -1
                            }
                            
                            //println("-----")
                            //println("q \(q)")
                            //println("dhyp \(dhyp)")
                            //println("dratio \(dratio)")
                            //println("dx \(dx)")
                            //println("dy \(dy)")
                            //println("wx \(wx)")
                            //println("wy \(wy)")
                            
                            // @todo find the angle of the path and make a
                            // rectangle that matches the slope... ideally
                            // matching up all points. Then see if you can
                            // add a gradient to the rect in the correct dir.
                            //CGContextSetLineWidth(ctx, 6.0)
                            CGContextBeginPath(ctx)
                            CGContextMoveToPoint(ctx, px, py)
                            CGContextAddLineToPoint(ctx, cx, cy)
                            CGContextAddLineToPoint(ctx, cx + wx, cy + wy)
                            CGContextAddLineToPoint(ctx, px + wx, py + wy)
                            CGContextAddLineToPoint(ctx, ppx, ppy)
                            CGContextAddLineToPoint(ctx, px, py)
                            CGContextSetFillColorWithColor(ctx, speedColor)
                            CGContextFillPath(ctx)
                            //CGContextStrokePath(ctx);
                            
                            //CGContextSetLineWidth(ctx, 2.0)
                            //var center = CGPointMake(cx, cy)
                            //CGContextAddArc(ctx, center.x, center.y, CGFloat(3.0), CGFloat(0), CGFloat(2*M_PI), Int32(0))
                            //CGContextSetFillColorWithColor(ctx, speedColor);
                            //CGContextFillPath(ctx);
                            ////CGContextStrokePath(context);
                            
                            // Draw a mile marker
                            total += p.distance.doubleValue * Double(0.00062137)
                            mileTest = Int(total)
                            if mileTest > mileCounter {
                                mileCounter = mileTest
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
                    //ptime = p.date
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
