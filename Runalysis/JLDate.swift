//
//  JLDate.swift
//  Runalysis
//
//  Created by Kevin Hankens on 7/28/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
* Add a days property to the Int class.
*/
extension Int {
    var days: NSDateComponents {
    let comps = NSDateComponents()
        comps.day = self;
        return comps
    }
}

/*!
* Add a property to locate a date in the future or past.
*/
extension NSDateComponents {
    // Locate a date after today.
    var fromNow: NSDate {
    let cal = NSCalendar.currentCalendar()
        let date = cal.dateByAddingComponents(self, toDate: NSDate(), options: nil)
        return date!
    }
    
    // Locate a date prior to today.
    var beforeNow: NSDate {
    self.day *= -1
        let cal = NSCalendar.currentCalendar()
        let date = cal.dateByAddingComponents(self, toDate: NSDate(), options: nil)
        return date!
    }
}

/*!
 * @class
 *
 * Tracks the mapping between a date's NSDate and NSNumber
 * representation, e.g. 20140715.
 */
class JLDate: NSObject {
    
    /*!
     * Specifies the date format of numeric date representation, e.g. 20140715
     *
     * @return String
     */
    class func getDateFormat()->String {
        return "yyyyMMdd"
    }
    
    /*!
     * Specifies the date format of full date view including time.
     *
     * @return String
     */
    class func getDateFormatFull()->String {
        return "EEEE, MMM d h:mm"
    }
    
    /*!
     * Specifies the short date format.
     *
     * @return String
     */
    class func getDateFormatShort()->String {
        return "MM/dd/yyyy"
    }
    
    /*!
     * Specifies the medium date format.
     *
     * @return String
     */
    class func getDateFormatMedium()->String {
        return "EEEE, MMM d"
    }
    
    /*!
     * Specifies the "day" date format.
     *
     * @return String
     */
    class func getDateFormatDay()->String {
        return "EEEE"
    }
    
    /*!
     * Specifies the "day" date format.
     *
     * @return String
     */
    class func getDateFormatMonthDay()->String {
        return "MMM d"
    }
    
    /*!
     * Specifies the numeric day format, e.g. sunday = 1
     *
     * @return String
     */
    class func getDateFormatDayNumber()->String {
        return "c"
    }
   
    // The date of this object.
    var date: NSDate = NSDate()
    
    // The numeric representation of this object, e.g. 20140727
    var number: NSNumber = 0
    
    /*!
     * Factory method to create a JLDate object from the most recent week start.
     *
     * @param NSNumber number
     *   The date format "c" of the day that starts the week. e.g. Sun = 1
     *
     * @return JLDate
     */
    class func createFromWeekStart(number: NSNumber = 1)->JLDate {
        let day = JLDate.createFromDate(NSDate())
        let dayNumber = day.toStringFormat(JLDate.getDateFormatDayNumber())
        let format = NSDateFormatter()
        format.dateFormat = "c"
        let today = format.stringFromDate(NSDate()).toInt()
        var day_count = 0
        for i in [1,2,3,4,5,6,7] {
            if today == i {
                break
            }
            else {
                day_count++
            }
        }
        return JLDate.createFromDate(day_count.days.beforeNow)
    }
   
    /*!
     * Factory method to create a JLDate object from a date object.
     *
     * @param NSDate date
     *   The date to use for this object.
     *
     * @return JLDate
     */
    class func createFromDate(date: NSDate)->JLDate {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay, fromDate: date)
        
        let mileage = JLDate()
        mileage.date = calendar.dateFromComponents(components)!
        mileage.number = JLDate.dateToNumber(date)
        return mileage
    }
    
    /*!
     * Factory method to create a JLDate from a number object.
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
     * Factory method to create a JLDate object relative to another.
     *
     * @param JLDate day
     *   The JLDate to use as a reference point.
     * @param NSNumber count
     *   The number of days +/- to move.
     *
     * @return JLDate
     */
    class func createRelativeDay(day: JLDate, count: NSNumber)->JLDate {
        let ti = 60*60*24*(count.doubleValue)
        return JLDate.createFromDate(day.date.dateByAddingTimeInterval(ti))
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
        return date!
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
        let mileage = NSNumber(integer:num!)
        return mileage
    }
    
    /*!
     * Updates the internal date by specifying an NSDate object.
     *
     * @param NSDate date
     *
     * @return void
     */
    func updateByDate(date: NSDate) {
        self.date = date
        self.number = JLDate.dateToNumber(date)
    }
    
    /*!
     * Updates the internal date by specifying an NSNumber object.
     *
     * @param NSNumber number
     *
     * @return void
     */
    func updateByNumber(number: NSNumber) {
        self.date = JLDate.numberToDate(self.number)
        self.number = number
    }
    
    /*!
     * Produce a JLDate object in the future.
     *
     * @param NSNumber increment
     *   (Optional) How many days in the future to jump.
     *
     * @return JLDate
     */   
    func nextDay(increment: NSNumber = 1)->JLDate {
        return JLDate.createRelativeDay(self, count: increment)
    }
    
    /*!
     * Produce a JLDate object in the past
     *
     * @param NSNumber increment
     *   (Optional) How many days in the future to jump.
     *
     * @return JLDate
     */
    func prevDay(increment: NSNumber = 1)->JLDate {
        return JLDate.createRelativeDay(self, count: increment.doubleValue * -1)
    }
  
    /*!
     * Creates a "day" string of the date.
     *
     * @return String
     */
    func toStringDay()->String {
        return self.toStringFormat(JLDate.getDateFormatDay())
    }
    
    /*!
     * Creates a short human-readable date string.
     *
     * @return String
     */
    func toStringShort()->String {
        return self.toStringFormat(JLDate.getDateFormatShort())
    }
    
    /*!
     * Creates a medium human-readable date string.
     *
     * @return String
     */
    func toStringMedium()->String {
        return self.toStringFormat(JLDate.getDateFormatMedium())
    }
    
    /**
     * Convert the current date to a specified format.
     *
     * @param String format
     *
     * @return String
     */
    func toStringFormat(format: String)->String {
        let dateFormat = NSDateFormatter()
        dateFormat.dateFormat = format
        return dateFormat.stringFromDate(self.date)
    }
}
