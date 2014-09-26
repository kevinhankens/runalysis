//
//  WeekSummaryView.swift
//  Runalysis
//
//  Created by Kevin Hankens on 9/25/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class WeekSummaryView: UIView {
    
    var summaryCells: [WeekSummaryCell] = []

    var mileage: [Mileage] = []
    
    var dateLabel: UILabel?
    
    var dateLabelAlert: UILabel?
    
    var mileageStore: MileageStore?
    
    var routeStore: RouteStore?
    
    var sunday: JLDate = JLDate.createFromDate(NSDate())
    
    var daysOfWeek: [NSNumber] = [1,2,3,4,5,6,7]
    
    var headerMinY = CGFloat(0)
    
    var headerHeight = CGFloat(50)
    
    var controller: UIViewController?
    
    class func createWeekSummaryView(frame: CGRect, mileageStore: MileageStore, routeStore: RouteStore, sunday: JLDate, controller: UIViewController)->WeekSummaryView {
        
        let container = WeekSummaryView(frame: frame)
        container.mileageStore = mileageStore
        container.routeStore = routeStore
        container.sunday = sunday
        container.controller = controller
        
        var ypos = CGFloat(0)
        
        let dateView = UILabel(frame: CGRect(x: 0, y: ypos, width: container.bounds.width, height: 30))
        dateView.textColor = GlobalTheme.getNormalTextColor()
        dateView.textAlignment = NSTextAlignment.Center
        container.dateLabel = dateView
        container.setDateLabel()
        container.addSubview(dateView)
        
        let dateViewHi = UILabel(frame: CGRect(x: 0, y: ypos, width: container.bounds.width, height: 30))
        dateViewHi.textColor = GlobalTheme.getNormalTextAlertColor()
        dateViewHi.textAlignment = NSTextAlignment.Center
        dateViewHi.alpha = 0.0
        container.dateLabelAlert = dateViewHi
        container.setDateLabel()
        container.addSubview(dateViewHi)
        
        // Space for the graphic.
        container.headerMinY = ypos + dateView.frame.height
        ypos = container.headerMinY + container.headerHeight + 10
        
        var dayNum = container.sunday
        for day in container.daysOfWeek {
            let dayView = WeekSummaryCell.createWeekSummaryCell(CGRectMake(0, ypos, container.frame.width, 30), mileageStore: mileageStore, routeStore: routeStore, dayNum: dayNum, controller: controller)
            container.summaryCells.append(dayView)
            container.addSubview(dayView)

            ypos += dayView.frame.height + CGFloat(10)
            dayNum = dayNum.nextDay()
        }
        
        var f = CGRectMake(container.frame.minX, container.frame.minY, container.frame.width, ypos)
        container.frame = f
        container.sizeToFit()
    
        return container
    }
    
    func setDateLabel() {
        let endDate = self.sunday.nextDay(increment: 6)
        if let v = self.dateLabel? {
            if let vh = self.dateLabelAlert? {
                let format = NSDateFormatter()
                format.dateFormat = JLDate.getDateFormatMonthDay()
                let text = "< \(format.stringFromDate(self.sunday.date)) - \(format.stringFromDate(endDate.date)) >"
                v.text = text
                vh.text = text
                vh.alpha = 1.0
                UIView.animateWithDuration(1.0, animations: {vh.alpha = 0.0})
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, GlobalTheme.getBackgroundColor().CGColor);
        CGContextFillRect(context, self.bounds)
        
        // The max mileage.
        var vmax = Double(0)
        
        // The vertical scale.
        var vscale:CGFloat = 0
        
        // Tracks the mileage for each day of the week.
        var mileage = [[0.0,0.0,0.0,0.0,0.0,0.0,0.0],[0.0,0.0,0.0,0.0,0.0,0.0,0.0]]
        
        let mileageCells = self.summaryCells
        
        // Locate the maximum value to determine graph scale.
        var i = 0
        for cell in mileageCells {
            mileage[0][i] = cell.plannedValue
            mileage[1][i] = cell.actualValue
            
            if cell.plannedValue > vmax && cell.plannedValue > cell.actualValue {
                vmax = cell.plannedValue
            }
            else if cell.actualValue > vmax {
                vmax = cell.actualValue
            }
            i++
        }
        
        // Determine the vertical scale for each point.
        vscale = self.headerHeight/CGFloat(vmax)
        
        // Clear the context to start over.
        CGContextFillRect(context, self.bounds)
        CGContextSetLineWidth(context, 2.0)
        
        var start = true
        let increment = (self.frame.width - 20) / 6
        
        // Iterate over planned/actual and chart the mileage.
        var type = 0
        for color in [GlobalTheme.getPlannedColor(), GlobalTheme.getActualColor()] {
            CGContextSetStrokeColorWithColor(context, color.CGColor)
            var xval = CGFloat(10.0)
            var yval = CGFloat(0.0)
            for i in 0...6 {
                yval = CGFloat(mileage[type][i]) * vscale
                if (isnan(yval)) {
                    yval = CGFloat(0.0)
                }
                yval = yval == CGFloat(0.0) ? CGFloat(1.0) : yval
                if start {
                    CGContextMoveToPoint(context, xval, self.headerMinY + self.headerHeight - yval)
                    start = false
                }
                else {
                    CGContextAddLineToPoint(context, xval, self.headerMinY + self.headerHeight - yval)
                }
                xval += increment
            }
            start = true
            CGContextStrokePath(context)
            type++
        }
    }
    
    func updateView(sunday: JLDate) {
        self.sunday = sunday
        self.setDateLabel()
        var day = sunday
        for cell in self.summaryCells {
            cell.dayNum = day
            cell.updateValues()
            day = day.nextDay(increment: 1)
        }
        self.setNeedsDisplay()
    }
    
    func getMileage() {
    
    }

}