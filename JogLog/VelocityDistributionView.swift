//
//  VelocityDistributionView.swift
//  JogLog
//
//  Created by Kevin Hankens on 9/15/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class VelocityDistributionView: UIView {
    
    var routeSummary: RouteSummary?

    override func drawRect(rect: CGRect) {
    
        if let summary = self.routeSummary as? RouteSummary {
            let context = UIGraphicsGetCurrentContext()
            CGContextFillRect(context, self.bounds)
        
            let barWidth = (Int(self.frame.width - 40)/summary.distribution.count) - 5
            let barPadding = CGFloat(10)
        
            var tx = CGFloat(10)
            var ty = CGFloat(0)
            var w = CGFloat(barWidth)
            var h = self.bounds.height
            
            var speedColor = GlobalTheme.getSpeedOne().CGColor
        
            var high = 0
        
            for count in summary.distribution {
                if count > high {
                    high = count
                }
            }
        
            let scale = self.frame.height/CGFloat(high)
        
            var index = 0
            for count in summary.distribution {
                
                switch index {
                case 0:
                    speedColor = GlobalTheme.getSpeedOne().CGColor
                case 1:
                    speedColor = GlobalTheme.getSpeedTwo().CGColor
                case 2:
                    speedColor = GlobalTheme.getSpeedThree().CGColor
                case 3:
                    speedColor = GlobalTheme.getSpeedFour().CGColor
                case 4:
                    speedColor = GlobalTheme.getSpeedFive().CGColor
                default:
                    speedColor = GlobalTheme.getSpeedOne().CGColor
                }
                
                h = count == 0 ? CGFloat(1) : CGFloat(count)
                h *= scale
                var rectangle = CGRectMake(tx, ty, w, h);
                tx = tx + barWidth + barPadding
                CGContextSetFillColorWithColor(context, speedColor);
                CGContextFillRect(context, rectangle)
                index++
            }
        }
    }

}
