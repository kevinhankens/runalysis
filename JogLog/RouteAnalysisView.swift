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

    class func createRouteAnalysisView(cellHeight: CGFloat, cellWidth: CGFloat, x: CGFloat, y: CGFloat, routeSummary: RouteSummary)->RouteAnalysisView {
        
        let rav = RouteAnalysisView(frame: CGRect(x: x, y: y, width: cellWidth, height: cellHeight))
    
        rav.routeSummary = routeSummary
        
        var ypos = CGFloat(0.0)
        
        let dl = UILabel(frame: CGRectMake(10, ypos, rav.bounds.width, 20))
        dl.text = "-"
        dl.textColor = GlobalTheme.getNormalTextColor()
        rav.labelDate = dl
        rav.addSubview(dl)
        
        ypos += dl.bounds.height + 10
        
        let al = UILabel(frame: CGRectMake(10, ypos, rav.bounds.width, 20))
        al.text = "-"
        al.textColor = GlobalTheme.getNormalTextColor()
        rav.labelAverage = al
        rav.addSubview(al)
        
        rav.updateLabels()
        
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
