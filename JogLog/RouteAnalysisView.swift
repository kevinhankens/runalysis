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
    
    // Tracks the RouteSummary object.
    var routeSummary: RouteSummary?
    
    // Tracks the VelocityDistributionView object.
    var velocityDistributionView: VelocityDistributionView?
    
    // Tracks the MileSummaryView object.
    var mileSummaryView: MileSummaryView?
    
    // Tracks the label for the current date.
    var labelDate: UILabel?
    
    // Tracks the label for the average velocity.
    var labelAverage: UILabel?
    
    // Tracks the label for the chronograph/total time.
    var labelTimer: UILabel?
    
    /*!
     * Factory method to create a RouteAnalysisView object.
     *
     * @param CGFloat cellHeight
     * @param CGFloat cellWidth
     * @param CGFloat x
     * @param CGFloat y
     * @param RouteSummary routeSummary
     *
     * @return RouteAnalysisView
     */
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
        al.textColor = GlobalTheme.getAverageSpeedTextColor()
        al.font = UIFont.systemFontOfSize(40.0)
        rav.labelAverage = al
        rav.addSubview(al)
        
        ypos += al.bounds.height
        
        let tl = UILabel(frame: CGRectMake(10, ypos, rav.bounds.width, 20))
        tl.text = "-"
        tl.textColor = GlobalTheme.getNormalTextColor()
        rav.labelTimer = tl
        rav.addSubview(tl)
        
        ypos += tl.bounds.height + 10
        
        // @todo make a factory method for this.
        let dv = VelocityDistributionView(frame: CGRectMake(0, ypos, rav.bounds.width, 40.0))
        dv.routeSummary = routeSummary
        rav.addSubview(dv)
        rav.velocityDistributionView = dv
        
        // @todo make a factory method for this.
        ypos += dv.bounds.height + 10
        let mv = MileSummaryView(frame: CGRectMake(0, ypos, rav.bounds.width, rav.bounds.height))
        mv.routeSummary = routeSummary
        mv.sizeToFit()
        rav.addSubview(mv)
        rav.mileSummaryView = mv
        
        rav.updateLabels()
        rav.updateDuration(routeSummary.duration)
        
        rav.sizeToFit()
        
        ypos = ypos + CGFloat(mv.frame.height)
        let f = CGRectMake(x, y, rav.frame.width, ypos)
        rav.frame = f
        
        return rav
    }
    
    /*!
     * Gets the formatted total duration string.
     *
     * @param NSTimeInterval new_duration
     *
     * @return NSString
     */
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
    
    /*!
     * Sets the label with a new duration.
     *
     * @param NSTimeInterval new_duration
     */
    func updateDuration(new_duration: NSTimeInterval) {
        if let tl = self.labelTimer as? UILabel {
            tl.text = self.getDuration(new_duration)
        }
    }
    
    /*!
     * Sets the label text with current values.
     */
    func updateLabels() {
        var height = CGFloat(0)
        if let al = self.labelAverage as? UILabel {
            height += al.frame.height
            al.text = self.routeSummary!.getTotalAndPace()
        }
        
        if let dl = self.labelDate as? UILabel {
            if let summary = self.routeSummary as? RouteSummary {
                height += dl.frame.height
                let date = NSDate(timeIntervalSince1970:summary.routeId)
                let format = NSDateFormatter()
                format.dateFormat = JLDate.getDateFormatFull()
                dl.text = format.stringFromDate(date)
            }
        }
        
        if let vdv = self.velocityDistributionView as? VelocityDistributionView {
            height += vdv.frame.height
            vdv.setNeedsDisplay()
        }
        
        if let mv = self.mileSummaryView as? MileSummaryView {
            mv.updateLabels()
            height += mv.frame.height
            
            let f = CGRectMake(self.frame.minX, self.frame.minY, self.frame.width, height)
            self.frame = f
        }
    }
}
