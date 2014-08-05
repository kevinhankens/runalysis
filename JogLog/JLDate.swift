//
//  JLDate.swift
//  JogLog
//
//  Created by Kevin Hankens on 7/28/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * @class
 *
 * Tracks the mapping between a date's NSDate and NSNumber
 * representation, e.g. 20140715.
 */
class JLDate {
    
    /*!
     * Specifies the date format of numeric date representation, e.g. 20140715
     *
     * @return NSString
     */
    class func getDateFormat()->NSString {
        return "yyyyMMdd"
    }
    
    /*!
     * Specifies the short date format.
     *
     * @return NSString
     */
    class func getDateFormatShort()->NSString {
        return "MM/dd/yyyy"
    }
    
    /*!
     * Specifies the medium date format.
     *
     * @return NSString
     */
    class func getDateFormatMedium()->NSString {
        return "EEEE, MMM d"
    }
   
    // The date of this object.
    var date: NSDate = NSDate()
    
    // The numeric representation of this object, e.g. 20140727
    var number: NSNumber = 0
   
    /*!
     * Factory method to create an ID from a date object.
     *
     * @param NSDate date
     *   The date to use for this ID.
     *
     * @return JLDate
     */
    class func createFromDate(date: NSDate)->JLDate {
        let mileage = JLDate()
        mileage.date = date
        mileage.number = JLDate.dateToNumber(date)
        return mileage
    }
    
    /*!
     * Factory method to create an ID from a number
     *
     * @param NSNumber number
     *   The numeric representation, e.g. 20140727
     *
     * @return JLDate
     */
    class func createFromNumber(number: NSNumber)->JLDate {
        let mileage = JLDate()
        mileage.date = JLDate.numberToDate(number)
        mileage.number = number
        return mileage
    }

    /*!
     * Convert a number to a date object.
     *
     * @param NSNumber number
     *   The numeric representation, e.g. 20140727
     *
     * @return NSDate
     */
    class func numberToDate(mileage: NSNumber)->NSDate {
        let format = NSDateFormatter()
        format.dateFormat = JLDate.getDateFormat()
        let date = format.dateFromString(mileage.stringValue)
        return date
    }
    
    /*!
     * Convert a date object to a numeric representation.
     *
     * @param NSDate date
     *   The date of the ID.
     *
     * @return NSNumber
     */   
    class func dateToNumber(date: NSDate)->NSNumber {
        let format = NSDateFormatter()
        format.dateFormat = JLDate.getDateFormat()
        let num = format.stringFromDate(date).toInt()
        let mileage = NSNumber.numberWithInteger(num!)
        return mileage
    }
   
    /*!
     * Creates a short human-readable date string.
     *
     * @return NSString
     */
    func toStringShort()->NSString {
        return self.toStringFormat(JLDate.getDateFormatShort())
    }
    
    /*!
     * Creates a medium human-readable date string.
     *
     * @return NSString
     */
    func toStringMedium()->NSString {
        return self.toStringFormat(JLDate.getDateFormatMedium())
    }
    
    /**
     * Convert the current date to a specified format.
     *
     * @param NSString format
     *
     * @return NSString
     */
    func toStringFormat(format: NSString)->NSString {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.stringFromDate(self.date)
    }
}