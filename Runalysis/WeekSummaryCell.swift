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

    var plannedLabel: UILabel?
    
    var plannedLabelHi: UILabel?
    
    var plannedValue: Double = 0
    
    var actualLabel: UILabel?
    
    var actualLabelHi: UILabel?
    
    var actualValue: Double = 0
    
    var title: String = ""
    
    class func createWeekSummaryCell(frame: CGRect, dayNum: JLDate, title: String)->WeekSummaryCell {
        
        let container = WeekSummaryCell(frame: frame)
        container.dayNum = dayNum
        container.title = title
        
        var xpos = CGFloat(0)
        var height = GlobalTheme.getNormalFontHeight()
        
        let dayView = UILabel(frame: CGRect(x: xpos, y: 0, width: container.bounds.width/2, height: height))
        dayView.text = title
        dayView.font = GlobalTheme.getNormalFont()
        dayView.textColor = GlobalTheme.getNormalTextColor()
        dayView.textAlignment = NSTextAlignment.Center
        container.addSubview(dayView)
        
        xpos += dayView.frame.width
        
        let plannedView = UILabel(frame: CGRect(x: xpos, y: 0, width: container.bounds.width/4 - 5, height: height))
        plannedView.textColor = GlobalTheme.getPlannedColor()
        plannedView.font = GlobalTheme.getNormalFont()
        plannedView.textAlignment = NSTextAlignment.Right
        container.plannedLabel = plannedView
        container.addSubview(plannedView)
        
        let plannedViewHi = UILabel(frame: CGRect(x: xpos, y: 0, width: container.bounds.width/4 - 5, height: height))
        plannedViewHi.textColor = GlobalTheme.getNormalTextColor()
        plannedViewHi.font = GlobalTheme.getNormalFont()
        plannedViewHi.alpha = 0.0
        plannedViewHi.textAlignment = NSTextAlignment.Right
        container.plannedLabelHi = plannedViewHi
        container.addSubview(plannedViewHi)
        
        xpos += plannedView.frame.width
        
        let separatorView = UILabel(frame: CGRect(x: xpos, y: 0, width: 10, height: height))
        separatorView.textColor = GlobalTheme.getNormalTextColor()
        separatorView.font = GlobalTheme.getNormalFont()
        separatorView.text = "/"
        separatorView.textAlignment = NSTextAlignment.Center
        container.addSubview(separatorView)
        xpos += separatorView.frame.width
        
        let actualView = UILabel(frame: CGRect(x: xpos, y: 0, width: container.bounds.width/4 - 5, height: height))
        actualView.textColor = GlobalTheme.getActualColor()
        actualView.font = GlobalTheme.getNormalFont()
        actualView.textAlignment = NSTextAlignment.Left
        container.actualLabel = actualView
        container.addSubview(actualView)
        
        let actualViewHi = UILabel(frame: CGRect(x: xpos, y: 0, width: container.bounds.width/4 - 5, height: height))
        actualViewHi.textColor = GlobalTheme.getNormalTextColor()
        actualViewHi.font = GlobalTheme.getNormalFont()
        actualViewHi.textAlignment = NSTextAlignment.Left
        actualViewHi.alpha = 0.0
        container.actualLabelHi = actualViewHi
        container.addSubview(actualViewHi)
        
        container.updateValues()
        

    
        return container
    }
    
    func updateValues() {
        if let p = self.plannedLabel? {
            if let ph = self.plannedLabelHi? {
                let text = self.getMileageLabel(self.plannedValue)
                p.text = text
                ph.text = text
                ph.alpha = 1.0
                UIView.animateWithDuration(0.75, animations: {ph.alpha = 0.0})
            }
        }
        
        if let a = self.actualLabel? {
            if let ah = self.actualLabelHi? {
                let text = self.getMileageLabel(self.actualValue)
                a.text = text
                ah.text = text
                ah.alpha = 1.0
                UIView.animateWithDuration(0.75, animations: {ah.alpha = 0.0})
            }
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