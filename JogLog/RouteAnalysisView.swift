//
//  RouteAnalysisView.swift
//  JogLog
//
//  Created by Kevin Hankens on 9/9/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class RouteAnalysisView: UIView {
    
    var routeSummary: RouteSummary?
    
    var labelDate: UILabel?
    
    var labelAverage: UILabel?
    
    var labelTimer: UILabel?
    
    class func createRouteAnalysisView(cellHeight: CGFloat, cellWidth: CGFloat, x: CGFloat, y: CGFloat, routeSummary: RouteSummary)->RouteAnalysisView {
        
        let rav = RouteAnalysisView(frame: CGRect(x: x, y: y, width: cellWidth, height: cellHeight))
    
        rav.routeSummary = routeSummary
        
        var ypos = CGFloat(0.0)
        
        let dl = UILabel(frame: CGRectMake(10, ypos, rav.bounds.width, 20))
        dl.text = "-"
        dl.textColor = GlobalTheme.getNormalTextColor()
        rav.labelDate = dl
        rav.addSubview(dl)
        
        ypos += dl.bounds.height
        
        let al = UILabel(frame: CGRectMake(10, ypos, rav.bounds.width, 45))
        al.text = "-"
        al.textColor = GlobalTheme.getSpeedThree()
        al.font = UIFont.systemFontOfSize(40.0)
        rav.labelAverage = al
        rav.addSubview(al)
        
        ypos += al.bounds.height
        
        let tl = UILabel(frame: CGRectMake(10, ypos, rav.bounds.width, 20))
        tl.text = "-"
        tl.textColor = GlobalTheme.getNormalTextColor()
        rav.labelTimer = tl
        rav.addSubview(tl)
        
        rav.updateLabels()
        rav.updateDuration(routeSummary.duration)
        
        rav.sizeToFit()
        
        return rav
    }
    
    func getDuration(new_duration: NSTimeInterval)->NSString {
        if let summary = self.routeSummary as? RouteSummary {
            let tmp_minutes = Int(new_duration/60.0)
            let seconds = new_duration - (Double(tmp_minutes) * Double(60))
            let rounded_seconds = round(seconds * 10)/10
            let hours = Int(tmp_minutes/60)
            let minutes = tmp_minutes - (hours * 60)
        
            var string_seconds = "\(rounded_seconds)"
            if (rounded_seconds < 10) {
                string_seconds = "0\(rounded_seconds)"
            }
            var string_minutes = "\(minutes)"
            if (minutes < 10) {
                string_minutes = "0\(minutes)"
            }
            var string_hours = "\(hours)"
            if (hours < 10) {
                string_hours = "0\(hours)"
            }
        
            return "\(string_hours):\(string_minutes):\(string_seconds)"
        }
        return "00:00:00"
    }
    
    func updateDuration(new_duration: NSTimeInterval) {
        if let tl = self.labelTimer as? UILabel {
            tl.text = self.getDuration(new_duration)
        }
    }
    
    func updateLabels() {
        if let al = self.labelAverage as? UILabel {
            al.text = self.routeSummary!.getTotalAndPace()
        }
        
        if let dl = self.labelDate as? UILabel {
            if let summary = self.routeSummary as? RouteSummary {
                let date = NSDate(timeIntervalSince1970:summary.routeId)
                let format = NSDateFormatter()
                format.dateFormat = JLDate.getDateFormatFull()
                dl.text = format.stringFromDate(date)
            }
        }
    }
}
