//
//  SummaryCell.swift
//  Runalysis
//
//  Created by Kevin Hankens on 7/23/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class SummaryCell: UIView {
  
    // The date this week begins with.
    var beginDate: NSDate = NSDate()
    
    // The date this week ends with.
    var endDate: NSDate = NSDate()
    
    // The label containing the date.
    var dateLabel: UILabel?
    
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
   
    /*!
     * Factory method to create a SummaryCell.
     *
     * @param CGFloat cellHeight
     * @param CGFloat cellWidth
     * @param CGFloat cellY
     * @param NSDate beginDate
     * @param NSDate endDate
     *
     * @return SummaryCell
     */
    class func createCell(cellHeight: CGFloat, cellWidth:
        CGFloat, cellY: CGFloat, beginDate: NSDate, endDate: NSDate)->SummaryCell {
            
        // @todo this needs more dynamic boundaries.
            
        let container = SummaryCell(frame: CGRectMake(0, cellY, cellWidth, cellHeight))
            
        let mpos = container.frame.minY - container.frame.height/4
    
        let planned = UILabel(frame: CGRect(x: 0, y: mpos, width: 50.00, height: container.bounds.height))
        planned.textColor = UIColor.whiteColor()
        planned.textAlignment = NSTextAlignment.Center
        container.plannedLabel = planned
        container.addSubview(planned)
            
        let actual = UILabel(frame: CGRect(x: cellWidth - 50, y: mpos, width: 50.00, height: container.bounds.height))
        actual.textColor = UIColor.whiteColor()
        actual.textAlignment = NSTextAlignment.Center
        container.actualLabel = actual
        container.addSubview(actual)
            
        let headerDate = UILabel(frame: CGRect(x: 0, y: 0, width: container.bounds.width, height: 50.0))
        headerDate.textAlignment = NSTextAlignment.Center
        headerDate.textColor = UIColor.whiteColor()
        container.dateLabel = headerDate
        container.updateDate(beginDate, endDate: endDate)
        container.addSubview(headerDate)
            
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
        CGContextSetFillColorWithColor(context, GlobalTheme.getBackgroundColor().CGColor);
        CGContextFillRect(context, self.bounds)
    
        // The max mileage.
        var vmax = 0.0
        
        // The vertical scale.
        var vscale:CGFloat = 0
        
        // The vertical boundary.
        let vbounds = CGFloat(40.0)
        
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
            
            if l.value > vmax && l.value > r.value {
                vmax = l.value
            }
            else if r.value > vmax {
                vmax = r.value
            }
            i++
        }
       
        // Determine the vertical scale for each point.
        vscale = CGFloat(self.frame.height - vbounds)/CGFloat(vmax)
       
        // Clear the context to start over.
        CGContextFillRect(context, self.bounds)
        CGContextSetLineWidth(context, 2.0)
        
        var start = true
        let increment = (self.frame.width - 100) / 6
    
        // Iterate over planned/actual and chart the mileage.
        var type = 0
        for color in [GlobalTheme.getPlannedColor(), GlobalTheme.getActualColor()] {
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            var xval = CGFloat(50.0)
            var yval = CGFloat(0.0)
            for i in 0...6 {
                yval = CGFloat(mileage[type][i]) * vscale
                if (isnan(yval)) {
                    yval = CGFloat(0.0)
                }
                yval = yval == CGFloat(0.0) ? CGFloat(1.0) : yval
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
    
    /*!
     * Updates the header to contain a new begin and end date.
     *
     * This also updates the label accordingly.
     *
     * @param NSDate beginDate
     * @param NSDate endDate
     *
     * @return void
     */
    func updateDate(beginDate: NSDate, endDate: NSDate) {
        self.beginDate = beginDate
        self.endDate = endDate
        self.updateLabel()
    }
    
    /*!
     * Updates the label containing the dates.
     *
     * @return void
     */
    func updateLabel() {
        let v = self.dateLabel!
        let format = NSDateFormatter()
        format.dateFormat = "MMM d"
        v.text = "< \(format.stringFromDate(self.beginDate)) - \(format.stringFromDate(self.endDate)) >"
    }


}
