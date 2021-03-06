//
//  AltitudeVelocityView.swift
//  Runalysis
//
//  Created by Kevin Hankens on 9/19/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * Provides a visual analysis of altitude and velocity in time series.
 */
class AltitudeVelocityView: UIView {

    // Tracks the RouteSummary object.
    var routeSummary: RouteSummary?
    
    // The horizontal distance between each point.
    var xIncrement = CGFloat(0)
    
    // The lowest altitude.
    var aLow = Double(0)
    
    // The highest altitude.
    var aHigh = Double(0)
    
    // The lowest velocity.
    var vLow = Double(0)
    
    // The highest velocity.
    var vHigh = Double(0)
    
    // The scale of altitude differential to the vertical space.
    var aScale = CGFloat(0)
    
    // The scale of velocity differential to the vertical space.
    var vScale = CGFloat(0)
    
    var vBgAlpha = CGFloat(0.75)
    
    /*!
     * Determines the relationships between the data differentials and the visual space.
     *
     * @return void
     */
    func determineRatios() {
        var aLow = Double(0)
        var aHigh = Double(0)
        var vLow = Double(0)
        var vHigh = Double(0)
        
        // @todo the high/low calc probably belongs in the RouteSummary
        if let summary = self.routeSummary {
            
            if let points = summary.points {
                var count = CGFloat(points.count)
                if count <= 0 {
                    count = 1
                }
                
                // Find the horizontal space between points considering margins.
                self.xIncrement = (self.frame.width - 20)/count
                
                // We skip the first point because the velocity is 0
                // and the next point will have a similar altitude.
                var zeroSkipped = false
                
                for point in points {
                    
                    if !zeroSkipped {
                        zeroSkipped = true
                        continue
                    }
                    
                    if let p = point as? Route {
                        
                        // Ensure that our velocity is not null.
                        let testv: AnyObject? = point.valueForKey("velocity")
                        
                        if let v = testv as? NSNumber {
                            // Determine the high and low points for altitude
                            // and velocity as this determines the scale.
                            if aLow == Double(0) || p.altitude_raw < aLow {
                                aLow = p.altitude_raw
                            }
                            else if aHigh == 0.0 || p.altitude_raw > aHigh {
                                aHigh = p.altitude_raw
                            }
                            if !isnan(p.velocity_raw) && (vLow == 0.0 || p.velocity_raw < vLow) {
                                vLow = p.velocity_raw
                            }
                            else if !isnan(p.velocity_raw) && (vHigh == 0.0 || p.velocity_raw > vHigh) {
                                vHigh = p.velocity_raw
                            }
                        }
                    }
                }

                self.aLow = aLow
                self.aHigh = aHigh
                //self.vLow = vLow
                self.vLow = 0.0
                self.vHigh = vHigh
                
                // Determine the scale based on the differentials.
                let ar = CGFloat(self.aHigh - self.aLow)
                if ar > 0 {
                    self.aScale = self.frame.height/ar
                }
                else {
                    self.aScale = self.frame.height/10
                }
                
                let vr = CGFloat(self.vHigh - self.vLow)
                if vr > 0 {
                    self.vScale = self.frame.height/vr
                }
                else {
                    self.vScale = self.frame.height/10
                }
            }
        }
    }

    /*!
     * Overrides UIView::drawRect().
     */
    override func drawRect(rect: CGRect) {
        
        self.determineRatios()
        
        if let summary = self.routeSummary {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, GlobalTheme.getBackgroundColor().CGColor);
            CGContextFillRect(context, self.bounds)
            
            if let points = summary.points {
                
                // Track previous and current x,y values.
                var cx = CGFloat(10)
                var px = CGFloat(10)
                var ox = CGFloat(10)
                var by = self.frame.height
                var cay = CGFloat(0)
                var pay = CGFloat(0)
                var cvy = CGFloat(0)
                var pvy = CGFloat(0)
                
                // We need a previous point to draw a line, so we skip the first
                // element and just use that as our first previous point.
                var start = true
                var zeroSkipped = false
                
                // Draw the altitude graph. This is a CGPath that follows the
                // altitude graph then fills in the bottom to appear like a
                // land mass for better visual.
                CGContextBeginPath(context)
                CGContextMoveToPoint(context, cx, by);
                for point in points {
                    
                    if let p = point as? Route {
                        // Altitude.
                        cay = self.frame.height - (CGFloat(p.altitude.doubleValue - self.aLow)/2 * self.aScale)
                        CGContextAddLineToPoint(context, cx, cay)
                        pay = cay
                    
                    }
                    px = cx
                    cx += self.xIncrement
                }
                CGContextAddLineToPoint(context, cx, by);
                CGContextAddLineToPoint(context, ox, by);
                CGContextClosePath(context)
                CGContextSetFillColorWithColor(context, GlobalTheme.getAltitudeGraphColor().CGColor);
                CGContextFillPath(context)
                
                px = CGFloat(10)
                cx = CGFloat(10)
                
                var speedColor: CGColor
                // Draw the velocity graph.
                for point in points {
                    
                    // Velocity is always zero on the first point.
                    if !zeroSkipped {
                        zeroSkipped = true
                        continue
                    }
                    
                    if let p = point as? Route {
                        
                        speedColor = GlobalTheme.getSpeedColor(p.relVelMovingAvg, setAlpha: 1.0).CGColor
                        
                        // Ensure that the velocity is not null.
                        let testv: AnyObject? = point.valueForKey("velocityMovingAvg")
                        if let v = testv as? NSNumber {
                            // Velocity.
                            // @todo why does velocity eval to nan?
                            let cv = isnan(p.velocityMovingAvg) ? Double(0) : p.velocityMovingAvg
                            cvy = self.frame.height - (CGFloat(cv - self.vLow) * self.vScale)
                            if !start {
                                // Draw the relative velocity point
                                CGContextSetLineWidth(context, 2.0)
                                var center = CGPointMake(cx, cvy)
                                
                                CGContextAddArc(context, center.x, center.y, CGFloat(1.5), CGFloat(0), CGFloat(2*M_PI), Int32(0))
                                CGContextSetFillColorWithColor(context, speedColor);
                                CGContextFillPath(context);
                                CGContextBeginPath(context)
                                //CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
                                //CGContextMoveToPoint(context, px, pvy)
                                //CGContextAddLineToPoint(context, cx, cvy)
                                //CGContextStrokePath(context);
                                
                                // Draw the actual velocity
                                //let av = isnan(p.velocity.doubleValue) ? Double(0) : p.velocity.doubleValue
                                //let avy = self.frame.height - (CGFloat(av - self.vLow) * self.vScale)
                                //CGContextSetLineWidth(context, 2.0)
                                //center = CGPointMake(cx, avy)
                                //CGContextAddArc(context, center.x, center.y, CGFloat(1.5), CGFloat(0), CGFloat(2*M_PI), Int32(0))
                                //CGContextSetFillColorWithColor(context, speedColorBg);
                                //CGContextFillPath(context);
                            }
                            pvy = cvy
                        }
                    }
                    if start {
                        start = false
                    }
                    px = cx
                    cx += self.xIncrement
                    
                }
                
            }
        }
        
    }

}
