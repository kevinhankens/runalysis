//
//  WeekHeader.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/18/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * @class WeekHeader
 *
 * Creates a view of the main header with the currently viewed week's date.
 */
class WeekHeader: UIView {
 
    // The date this week begins with.
    var beginDate: NSDate = NSDate()
    // The date this week ends with.
    var endDate: NSDate = NSDate()
    // The label containing the date.
    var dateLabel: UILabel?

    /*!
     * Factory method to create a WeekHeader.
     *
     * @param cellHeight
     * @param cellWidth
     * @param beginDate
     * @param endDate
     *
     * @return WeekHeader
     */
    class func createHeader(cellHeight: Float, cellWidth:
        Float, beginDate: NSDate, endDate: NSDate)->WeekHeader {
    
        let header = WeekHeader(frame: CGRect(x: 0, y: 20, width: cellWidth, height: cellHeight))

        let headerDate = UILabel(frame: CGRect(x: 0, y: 0, width: header.bounds.width, height: 50.0))
        headerDate.textAlignment = NSTextAlignment.Center
        header.dateLabel = headerDate
        header.updateDate(beginDate, endDate: endDate)
        header.addSubview(headerDate)
            
        return header
    }
   
    /*!
     * Updates the header to contain a new begin and end date.
     *
     * This also updates the label accordingly.
     *
     * @param beginDate
     * @param endDate
     *
     * @return void
     */
    func updateDate(beginDate: NSDate, endDate: NSDate) {
        self.beginDate = beginDate
        self.endDate = endDate
        self.updateLabel()
    }

    /*!
     * Updates the label containing the dates.
     *
     *
     * @return void
     */
    func updateLabel() {
        let v = self.dateLabel!
        let format = NSDateFormatter()
        format.dateFormat = "MMM d"
        v.text = "< \(format.stringFromDate(self.beginDate)) - \(format.stringFromDate(self.endDate)) >"
    }

}