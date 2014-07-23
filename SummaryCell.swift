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
        
        CGContextFillRect(context, self.bounds)
        
        let mileageCells = self.cells!
        // @todo better handling of the increment value.
        let increment = (self.frame.width - 100) / 6
        // @todo scale the drawing to fit vertically
        let scale = self.frame.height
       
        // Gross.
        CGContextSetLineWidth(context, 2.0);
        // Draw the planned mileage.
        CGContextSetStrokeColorWithColor(context, self.plannedColor.CGColor);
        var xval = CGFloat(50.0);
        var yval = CGFloat(0.0);
        var start = true
        for cell in mileageCells {
            var l = cell.leftControl! as RockerStepper
            var r = cell.rightControl! as RockerStepper
            yval = CGFloat(l.value) * 3
            if start {
                CGContextMoveToPoint(context, xval, self.frame.height - yval);
                start = false
            }
            else {
                CGContextAddLineToPoint(context, xval, self.frame.height - yval);
            }
            xval += increment
        }
        CGContextStrokePath(context);
        
        // Draw the actual mileage.
        CGContextSetStrokeColorWithColor(context, self.actualColor.CGColor);
        xval = CGFloat(50.0);
        yval = CGFloat(0.0);
        start = true
        for cell in mileageCells {
            var l = cell.leftControl! as RockerStepper
            var r = cell.rightControl! as RockerStepper
            yval = CGFloat(r.value) * 3
            if start {
                CGContextMoveToPoint(context, xval, self.frame.height - yval);
                start = false
            }
            else {
                CGContextAddLineToPoint(context, xval, self.frame.height - yval);
            }
            xval += increment
        }
        CGContextStrokePath(context);
    }

}