//
//  WeekSummaryCell.swift
//  Runalysis
//
//  Created by Kevin Hankens on 9/25/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class WeekSummaryCell: UIView {

    var dayNum: JLDate = JLDate.createFromDate(NSDate())
    
    var mileageStore: MileageStore?
    
    var routeStore: RouteStore?
    
    var plannedLabel: UILabel?
    
    var plannedValue: Double = 0
    
    var actualLabel: UILabel?
    
    var actualValue: Double = 0
    
    var controller: UIViewController?
    
    class func createWeekSummaryCell(frame: CGRect, mileageStore: MileageStore, routeStore: RouteStore, dayNum: JLDate, controller: UIViewController)->WeekSummaryCell {
        
        let container = WeekSummaryCell(frame: frame)
        container.dayNum = dayNum
        container.mileageStore = mileageStore
        container.routeStore = routeStore
        container.controller = controller
        
        var xpos = CGFloat(0)
        var height = container.frame.height
        
        let mileage = container.mileageStore!.getMileageForDate(dayNum)
        
        let dayView = UILabel(frame: CGRect(x: xpos, y: 0, width: container.bounds.width/2, height: height))
        dayView.textColor = GlobalTheme.getNormalTextColor()
        dayView.text = dayNum.toStringDay()
        dayView.textAlignment = NSTextAlignment.Center
        container.addSubview(dayView)
        
        xpos += dayView.frame.width
        
        let plannedView = UILabel(frame: CGRect(x: xpos, y: 0, width: container.bounds.width/4 - 10, height: height))
        plannedView.textColor = GlobalTheme.getPlannedColor()
        //plannedView.text = container.getMileageLabel(mileage.mileagePlanned)
        plannedView.textAlignment = NSTextAlignment.Right
        container.plannedLabel = plannedView
        container.addSubview(plannedView)
        
        xpos += plannedView.frame.width
        
        let separatorView = UILabel(frame: CGRect(x: xpos, y: 0, width: 10, height: height))
        separatorView.textColor = GlobalTheme.getNormalTextColor()
        separatorView.text = "/"
        separatorView.textAlignment = NSTextAlignment.Center
        container.addSubview(separatorView)
        xpos += separatorView.frame.width
        
        let actualView = UILabel(frame: CGRect(x: xpos, y: 0, width: container.bounds.width/4, height: height))
        actualView.textColor = GlobalTheme.getActualColor()
        //actualView.text = container.getMileageLabel(mileage.mileageActual)
        actualView.textAlignment = NSTextAlignment.Left
        container.actualLabel = actualView
        container.addSubview(actualView)
        
        container.updateValues()
        
        let tap = UITapGestureRecognizer(target: container, action: "respondToTapGesture:")
        container.addGestureRecognizer(tap)
    
        return container
    }
    
    func respondToTapGesture(tap: UITapGestureRecognizer) {
        if let c = self.controller as? ViewController {
            c.modalDayNum = self.dayNum
            c.modalRouteId = self.dayNum.number
            c.launchNoteView()
        }
    }
    
    func updateValues() {
        let mileage = self.mileageStore!.getMileageForDate(dayNum)
        
        self.plannedValue = mileage.mileagePlanned.doubleValue
        if let p = self.plannedLabel? {
            p.text = self.getMileageLabel(mileage.mileagePlanned.doubleValue)
        }
        self.actualValue = mileage.mileageActual.doubleValue
        if let a = self.actualLabel? {
            a.text = self.getMileageLabel(mileage.mileageActual.doubleValue)
        }
    }
    
    func getMileageLabel(miles: Double)->String {
        var mval = Int(miles)
        var dval = Int(round((miles - Double(mval)) * 100))
        var dtext = "\(dval)"
        if dval < 10 {
            dtext = "0\(dval)"
        }
        
        return "\(Int(miles)).\(dtext)"
    }

}