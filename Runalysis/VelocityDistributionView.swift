//
//  VelocityDistributionView.swift
//  Runalysis
//
//  Created by Kevin Hankens on 9/15/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * Displays a visual of the distribution of velocities.
 */
class VelocityDistributionView: UIView {
    
    /*!
     * Tracks the RouteSummary object.
     */
    var routeSummary: RouteSummary?
    
    /*!
     * Tracks the padding between the graph bars.
     */
    let barPadding = CGFloat(10)

    /*!
     * Overrides UIView::drawRect().
     *
     * Draw a visual representation of the velocity distribution.
     */
    override func drawRect(rect: CGRect) {
    
        if let summary = self.routeSummary {
            let context = UIGraphicsGetCurrentContext()
            CGContextSetFillColorWithColor(context, GlobalTheme.getBackgroundColor().CGColor);
            CGContextFillRect(context, self.bounds)
        
            let barWidth = (Int(self.frame.width - self.barPadding)/summary.mov_avg_dist.count) - Int(self.barPadding)
        
            var tx = CGFloat(10)
            var ty = CGFloat(0)
            var w = CGFloat(barWidth)
            var h = self.bounds.height
            
            var speedColor: CGColor
        
            // Find the high point, which will determine the scale.
            var high = 0
            for count in summary.mov_avg_dist {
                if count > high {
                    high = count
                }
            }
        
            let scale = self.frame.height/CGFloat(high)
        
            var index = 0
            for count in summary.mov_avg_dist {
                
                speedColor = GlobalTheme.getSpeedColor(index, setAlpha: 1.0).CGColor
                
                // Always draw at least a value of one because it looks better.
                h = count == 0 ? CGFloat(1) : CGFloat(count)
                h *= scale
                if h < CGFloat(2) {
                    h = CGFloat(2)
                }
                var rectangle = CGRectMake(tx, ty, w, h);
                tx = tx + CGFloat(barWidth) + self.barPadding
                CGContextSetFillColorWithColor(context, speedColor);
                CGContextFillRect(context, rectangle)
                index++
            }
        }
    }

}
