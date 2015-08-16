//
//  MileSummaryView.swift
//  Runalysis
//
//  Created by Kevin Hankens on 9/16/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class MileSummaryView: UIView {

    // Tracks the RouteSummary object.
    var routeSummary: RouteSummary?
    
    // Tracks the labels to display each mile's stats.
    var mileLabels: [UILabel] = []
    
    /*!
     * Updates the values of all the mile labels.
     */
    func updateLabels() {
    
        if let summary = self.routeSummary {
            for l in self.mileLabels {
                l.removeFromSuperview()
            }
            self.mileLabels.removeAll(keepCapacity: false)
            
            var ypos = CGFloat(0)
            
            var count = 1
            for time in summary.mileTimes {
                var l = UILabel(frame: CGRectMake(10, ypos, self.bounds.width, GlobalTheme.getNormalFontHeight()))
                l.text = "\(self.formatLabel(count, duration: time))"
                l.textColor = GlobalTheme.getNormalTextColor()
                l.font = GlobalTheme.getNormalFont()
                self.mileLabels.append(l)
                self.addSubview(l)
                ypos += l.frame.height + 5
                count++
            }
            let f = CGRectMake(self.frame.minX, self.frame.minY, self.frame.width, ypos + GlobalTheme.getNormalFontHeight())
            self.frame = f
            self.sizeToFit()
        }
    
    }
    
    /*!
     * Formats the label for each cell.
     *
     * @param Int count
     * @param Double duration
     *
     * @return String
     */
    func formatLabel(count: Int, duration: Double)->NSString {
    
        // @todo, this formatter probably belongs elsewhere.
        var minutes = Int(duration/60.0)
        var seconds = round((duration - (Double(minutes) * 60)) * 10)/10
        
        var seconds_string = "\(seconds)"
        if seconds == Double(60) {
            seconds = Double(0)
            seconds_string = "00.0"
            minutes++
        }
        else if seconds < 10 {
            seconds_string = "0\(seconds)"
        }
        
        var minutes_string = "\(minutes)"
        if minutes < 10 {
            minutes_string = "0\(minutes)"
        }
    
       
        return "\(count) \(RunalysisUnits.getUnitLabel()) @\(minutes_string):\(seconds_string)"
    }

}
