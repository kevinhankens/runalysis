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
    
    // Tracks the summary cells which list the mileage.
    var summaryCells: [WeekSummaryCell] = []
    
    // Tracks the summary cell with the weekly totals.
    var totalCell: WeekSummaryCell?

    // Tracks the Mileage objects.
    var mileage: [Mileage] = []
    
    // Tracks the date label.
    var dateLabel: UILabel?
    
    // Copy of the date label for alerts.
    var dateLabelAlert: UILabel?
    
    // Tracks the MileageStore object.
    var mileageStore: MileageStore?
    
    // Tracks the RouteStore object.
    var routeStore: RouteStore?
    
    // Tracks the current week start day.
    var sunday: JLDate = JLDate.createFromDate(NSDate())
    
    // The days of the week in NSDateFormat.
    var daysOfWeek: [NSNumber] = [1,2,3,4,5,6,7]
    
    // Tracks the top of the header for drawing.
    var headerMinY = CGFloat(0)
    
    // Tracks the height of the header for drawing.
    var headerHeight = CGFloat(50)
    
    // The view controller containing this view.
    var controller: UIViewController?
    
    /*!
     * Factory method to create a WeekSummaryView.
     *
     * @param CGRect frame
     * @param MileageStore mileageStore
     * @param RouteStore routeStore
     * @param JLDate sunday
     * @param UIViewController controller
     *
     * @return WeekSummaryView
     */
    class func createWeekSummaryView(frame: CGRect, mileageStore: MileageStore, routeStore: RouteStore, sunday: JLDate, controller: UIViewController)->WeekSummaryView {
        
        let container = WeekSummaryView(frame: frame)
        container.mileageStore = mileageStore
        container.routeStore = routeStore
        container.sunday = sunday
        container.controller = controller
        container.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        var ypos = CGFloat(0)
        let height = GlobalTheme.getNormalFontHeight()
        
        let dateView = UILabel(frame: CGRect(x: 45, y: ypos, width: container.bounds.width - 90, height: height))
        dateView.textColor = GlobalTheme.getNormalTextColor()
        dateView.font = GlobalTheme.getNormalFont()
        dateView.textAlignment = NSTextAlignment.Center
        dateView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        container.dateLabel = dateView
        container.setDateLabel()
        container.addSubview(dateView)
        
        let dateViewHi = UILabel(frame: CGRect(x: 0, y: ypos, width: container.bounds.width, height: height))
        dateViewHi.textColor = GlobalTheme.getNormalTextAlertColor()
        dateViewHi.font = GlobalTheme.getNormalFont()
        dateViewHi.textAlignment = NSTextAlignment.Center
        dateViewHi.alpha = 0.0
        dateViewHi.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        container.dateLabelAlert = dateViewHi
        container.setDateLabel()
        container.addSubview(dateViewHi)
        
        // Space for the graphic.
        container.headerMinY = ypos + dateView.frame.height + 10
        ypos = container.headerMinY + container.headerHeight + 10
        
        var dayNum = container.sunday
        for day in container.daysOfWeek {
            let dayView = WeekSummaryCell.createWeekSummaryCell(CGRectMake(0, ypos, container.bounds.width, 30), dayNum: dayNum, title: dayNum.toStringDay())
            dayView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            container.summaryCells.append(dayView)
            container.addSubview(dayView)
            
            let tap = UITapGestureRecognizer(target: container, action: "respondToTapGesture:")
            dayView.addGestureRecognizer(tap)

            ypos += dayView.frame.height + CGFloat(10)
            dayNum = dayNum.nextDay()
        }
        
        let total = WeekSummaryCell.createWeekSummaryCell(CGRectMake(0, ypos, container.bounds.width, 30), dayNum: dayNum, title: "")
        ypos += total.frame.height
        container.totalCell = total
        container.addSubview(total)
        
        container.updateView(sunday)
        
        var f = CGRectMake(container.frame.minX, container.frame.minY, container.frame.width, ypos)
        container.frame = f
        container.sizeToFit()
    
        return container
    }
    
    /*!
     * Responds to a tap on a day.
     *
     * @param UITapGestureRecognizer tap
     */
    func respondToTapGesture(tap: UITapGestureRecognizer) {
        if let c = self.controller as? ViewController {
            if let v = tap.view as? WeekSummaryCell {
                c.modalDayNum = v.dayNum
                c.modalRouteId = v.dayNum.number
                c.launchNoteView()
            }
        }
    }
    
    /*!
     * Sets the label text according to the currently viewed date.
     */
    func setDateLabel() {
        let endDate = self.sunday.nextDay(increment: 6)
        if let v = self.dateLabel {
            if let vh = self.dateLabelAlert {
                let format = NSDateFormatter()
                format.dateFormat = JLDate.getDateFormatMonthDay()
                let text = "< \(format.stringFromDate(self.sunday.date)) - \(format.stringFromDate(endDate.date)) >"
                v.text = text
                vh.text = text
                vh.alpha = 1.0
                UIView.animateWithDuration(0.75, animations: {vh.alpha = 0.0})
            }
        }
    }
    
    /*!
     * Draws the weekly graph showing a time series view of daily mileage.
     */
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
    
    /*!
     * Updates the view with a new start date.
     *
     * @param JLDate sunday
     */
    func updateView(sunday: JLDate) {
        self.sunday = sunday
        self.setDateLabel()
        
        var dayNum = self.sunday
        var plannedTotal = Double(0)
        var actualTotal = Double(0)
        
        if let store = self.mileageStore {
            var i = 0
            for i = 0; i < 7; i++ {
                var cell = self.summaryCells[i]
                cell.dayNum = dayNum
                var mileage = store.getMileageForDate(dayNum)
                dayNum = dayNum.nextDay(increment: 1)
                cell.actualValue = mileage.mileageActual.doubleValue
                cell.plannedValue = mileage.mileagePlanned.doubleValue
                plannedTotal += mileage.mileagePlanned.doubleValue
                actualTotal += mileage.mileageActual.doubleValue
                cell.updateValues()
            }
        }
        
        if let total = self.totalCell {
            total.plannedValue = plannedTotal
            total.actualValue = actualTotal
            total.updateValues()
        }
        
        self.setNeedsDisplay()
    }
    
}