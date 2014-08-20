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
    var routeStore = RouteStore()
    
    // The currently viewed route ID.
    var routeId: NSNumber = 0
    
    // A list of points for the current route.
    var points: [Route]?
    
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
    class func createRouteView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, routeId: NSNumber)->RouteView {
        
        let route = RouteView(frame: CGRectMake(x, y, width, width))
        
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
        self.routeId = id
        self.points = self.routeStore.getPointsForId(self.routeId)
        self.determineGrid()
        
        self.setNeedsDisplay()
    }
    
    /*!
     * Determines the scale of the route in terms of the current canvas.
     *
     * @return void
     */
    func determineGrid() {
        if let list = self.points as? [Route] {
            if !list.isEmpty {
                self.gridMinX = list[0].longitude
                self.gridMaxX = list[0].longitude
                self.gridMinY = list[0].latitude
                self.gridMaxY = list[0].latitude
            }
            for p in list {
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
        
        let diffX = self.gridMaxX - self.gridMinX
        let diffY = self.gridMaxY - self.gridMinY
        if (diffX > diffY) {
            if diffX > 0 {
                self.gridRatio = Double(self.frame.width) / fabs(diffX)
            }
            else {
                self.gridRatio = 1
            }
        }
        else {
            if diffY > 0 {
                self.gridRatio = Double(self.frame.height) / fabs(diffY)
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
        CGContextSetStrokeColorWithColor(context, GlobalTheme.getActualColor().CGColor)
        
        var px: CGFloat = 0.0
        var py: CGFloat = 0.0
        var start = true
        if let list = self.points as? [Route] {
            for p in list {
                px = CGFloat((p.longitude.doubleValue - self.gridMinX) * self.gridRatio)
                py = CGFloat(self.frame.height) - CGFloat((p.latitude.doubleValue - self.gridMinY) * self.gridRatio)
                //println("r: \(self.gridRatio)")
                //println("lat: \(p.latitude)")
                //println("lon: \(p.longitude)")
                //println("x: \(px)")
                //println("y: \(py)")
                //println("miny: \(self.bounds.minY)")
                //println("maxy: \(self.bounds.maxY)")
                //println("minx: \(self.bounds.minX)")
                //println("maxx: \(self.bounds.maxX)")
               
                if px <= self.bounds.maxX && px >= self.bounds.minX && py <= self.bounds.maxY && py >= self.bounds.minY {
                    if start {
                        CGContextMoveToPoint(context, px, py)
                        start = false
                    }
                    else {
                        CGContextAddLineToPoint(context, px, py)
                    }
                }
            }
            CGContextStrokePath(context)
        }
    }

}
