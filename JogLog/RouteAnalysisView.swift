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
        
        ypos += dl.bounds.height
        
        let tl = UILabel(frame: CGRectMake(10, ypos, rav.bounds.width, 20))
        tl.text = "-"
        tl.textColor = GlobalTheme.getNormalTextColor()
        rav.labelTimer = tl
        rav.addSubview(tl)
        
        rav.updateLabels()
        
        rav.sizeToFit()
        
        return rav
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
