//
//  WeekHeader.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/18/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class WeekHeader: UIView {
    
    var beginDate: NSDate = NSDate()
    var endDate: NSDate = NSDate()
    var dateLabel: UILabel?

    class func createHeader(cellHeight: Float, cellWidth:
        Float, beginDate: NSDate, endDate: NSDate)->WeekHeader {
    
        let header = WeekHeader(frame: CGRect(x: 0, y: 20, width: cellWidth, height: cellHeight))

        let headerDate = UILabel(frame: CGRect(x: 0, y: 0, width: header.bounds.width, height: 50.0))
        header.dateLabel = headerDate
        header.updateDate(beginDate, endDate: endDate)
        header.addSubview(headerDate)
            
        return header
    }
    
    func updateDate(beginDate: NSDate, endDate: NSDate) {
        self.beginDate = beginDate
        self.endDate = endDate
        self.updateLabel()
    }
    
    func updateLabel() {
        let v = self.dateLabel!
        let format = NSDateFormatter()
        format.dateFormat = "MMM d"
        v.text = "\(format.stringFromDate(self.beginDate)) - \(format.stringFromDate(self.endDate))"
    }

}