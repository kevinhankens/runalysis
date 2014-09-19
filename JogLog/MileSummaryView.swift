//
//  MileSummaryView.swift
//  JogLog
//
//  Created by Kevin Hankens on 9/16/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class MileSummaryView: UIView {

    var routeSummary: RouteSummary?
    
    var mileLabels: [UILabel] = []
    
    var labelHeight = CGFloat(20)
    
    func updateLabels() {
    
        if let summary = self.routeSummary? {
            for l in self.mileLabels {
                l.removeFromSuperview()
            }
            self.mileLabels.removeAll(keepCapacity: false)
            
            var ypos = CGFloat(0)
            
            var count = 1
            for time in summary.mileTimes {
                var l = UILabel(frame: CGRectMake(10, ypos, self.bounds.width, self.labelHeight))
                l.text = "\(self.formatLabel(count, duration: time))"
                l.textColor = GlobalTheme.getNormalTextColor()
                self.mileLabels.append(l)
                self.addSubview(l)
                ypos += l.frame.height + 5
                count++
            }
            let f = CGRectMake(self.frame.minX, self.frame.minY, self.frame.width, ypos + self.labelHeight)
            self.frame = f
            self.sizeToFit()
        }
    
    }
    
    func formatLabel(count: Int, duration: Double)->NSString {
    
        // @todo, this formatter probably belongs elsewhere.
        let minutes = Int(duration/60.0)
        let seconds = round((duration - (Double(minutes) * 60)) * 10)/10
        
        var minutes_string = "\(minutes)"
        if minutes < 10 {
            minutes_string = "0\(minutes)"
        }
    
        var seconds_string = "\(seconds)"
        if seconds < 10 {
            seconds_string = "0\(seconds)"
        }
        
        return "Mile \(count) @\(minutes_string):\(seconds_string)"
    }

}
