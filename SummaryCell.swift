//
//  SummaryCell.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/23/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class SummaryCell: UIView {
   
    // The total planned mileage for the week.
    var totalPlanned = 0.0
    
    // The total actual mileage for the week.
    var totalActual = 0.0
   
    // The label that contains the planned mileage.
    var plannedLabel: UILabel?
    
    // The label that contains the actual mileage.
    var actualLabel: UILabel?
   
    // A list of the RockerCell objects for summary.
    var cells: [RockerCell]?
   
    // Computed value to return the planned mileage color.
    var plannedColor: UIColor {
        return UIColor.blueColor()
    }
    
    // Computed value to return the actual mileage color.
    var actualColor: UIColor {
        return UIColor.greenColor()
    }
   
    /*!
     * Factory method to create a SummaryCell.
     *
     * @param CGFloat cellHeight
     * @param CGFloat cellWidth
     * @param CGFloat cellY
     *
     * @return SummaryCell
     */
    class func createCell(cellHeight: CGFloat, cellWidth:
        CGFloat, cellY: CGFloat)->SummaryCell {
            
        // @todo this needs more dynamic boundaries.
            
        let container = SummaryCell(frame: CGRectMake(0, cellY, cellWidth, 50.00))
    
        let planned = UILabel(frame: CGRect(x: 0, y: 0, width: 50.00, height: container.bounds.height))
        planned.textColor = container.plannedColor
        planned.textAlignment = NSTextAlignment.Center
        container.plannedLabel = planned
        container.addSubview(planned)
            
        let actual = UILabel(frame: CGRect(x: cellWidth - 50, y: 0, width: 50.00, height: container.bounds.height))
        actual.textColor = container.actualColor
        actual.textAlignment = NSTextAlignment.Center
        container.actualLabel = actual
        container.addSubview(actual)
            
        return container
    }
   
    /*!
     * Updates the values according to the latest list of RockerCell objects.
     *
     * @return void
     */
    func updateValues() {
        // @todo this should mark setNeedsDisplay().
        self.totalPlanned = 0.0
        self.totalActual = 0.0
        
        let mileageCells = self.cells!
        
        for cell in mileageCells {
            var l = cell.leftControl! as RockerStepper
            var r = cell.rightControl! as RockerStepper
            self.totalPlanned += l.value
            self.totalActual += r.value
        }
        
        let p = self.plannedLabel! as UILabel
        let a = self.actualLabel! as UILabel
        
        p.text = "\(RockerStepper.getLabel(Double(self.totalPlanned)))"
        a.text = "\(RockerStepper.getLabel(Double(self.totalActual)))"
    }
   
    /*!
     * Overrides drawRect.
     *
     * Creates the mileage graph for the week.
     *
     * @param CGRect rect
     *
     * @return void
     */
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
    
        // The max mileage.
        var vmax = 0.0
        
        // The vertical scale.
        var vscale = 0.0
        
        // The vertical boundary.
        let vbounds = CGFloat(10.0)
        
        // Tracks the mileage for each day of the week.
        var mileage = [[0.0,0.0,0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0,0.0,0.0]]
        
        let mileageCells = self.cells!
       
        // Locate the maximum value to determine graph scale.
        var i = 0
        for cell in mileageCells {
            var l = cell.leftControl! as RockerStepper
            var r = cell.rightControl! as RockerStepper
            mileage[0][i] = l.value
            mileage[1][i] = r.value
            println("l: \(l.value)")
            println("r: \(r.value)")
            
            if l.value > vmax && l.value > r.value {
                vmax = l.value
            }
            else if r.value > vmax {
                vmax = r.value
            }
            i++
        }
       
        // Determine the vertical scale for each point.
        vscale = (self.frame.height - vbounds)/vmax
       
        // Clear the context to start over.
        CGContextFillRect(context, self.bounds)
        CGContextSetLineWidth(context, 2.0)
        
        var start = true
        let increment = (self.frame.width - 100) / 6
    
        // Iterate over planned/actual and chart the mileage.
        var type = 0
        for color in [self.plannedColor, self.actualColor] {
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            var xval = CGFloat(50.0)
            var yval = CGFloat(0.0)
            for i in 0...6 {
                yval = CGFloat(mileage[type][i]) * CGFloat(vscale)
                println("\(yval)")
                if (isnan(yval)) {
                    yval = CGFloat(0.0)
                }
                if start {
                    CGContextMoveToPoint(context, xval, self.frame.height - yval)
                    start = false
                }
                else {
                    CGContextAddLineToPoint(context, xval, self.frame.height - yval)
                }
                xval += increment       
            }
            start = true
            CGContextStrokePath(context)
            type++
        }
    }

}