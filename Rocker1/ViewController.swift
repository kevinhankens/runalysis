//
//  ViewController.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import UIKit

/*!
 * Add a days property to the Int class.
 */
extension Int {
    var days: NSDateComponents {
    let comps = NSDateComponents()
        comps.day = self * -1;
        return comps
    }
}

/*!
 * Add a property to locate a date in the future.
 */
extension NSDateComponents {
    var fromNow: NSDate {
    let cal = NSCalendar.currentCalendar()
        let date = cal.dateByAddingComponents(self, toDate: NSDate.date(), options: nil)
        return date
    }
}


/*!
 * Add a method to output an NSDate object.
 */
extension NSDate {
    /*!
     * Converts a date to a RockerCell-compatible id. e.g. 20140715
     *
     * @return NSNumber
     */
    func toRockerId()->NSNumber {
        let format = NSDateFormatter()
        format.dateFormat = "yyyyMMdd"
        let num = format.stringFromDate(self).toInt()
        return num!
    }
    
    /*!
     * Gets the date N days after today.
     *
     * @param increment
     *   The number of days to move forward.
     * 
     * @return NSDate
     */
    func nextDay(increment: NSNumber = 1)->NSDate {
        let ti = 60*60*24*(increment.doubleValue)
        return self.dateByAddingTimeInterval(ti)
    }
    
    /*!
     * Gets the date N days prior to today.
     *
     * @param increment
     *   The number of days to move forward.
     * 
     * @return NSDate
     */   
    func prevDay(increment: NSNumber = 1)->NSDate {
        let negative = Double(increment.intValue * -1)
        let ti = 60*60*24*negative
        return self.dateByAddingTimeInterval(ti)
    }
 
}

/*!
 * Main view controller.
 */
class ViewController: UIViewController {
    
    let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var mileageCells: [RockerCell] = []
    var headerCell: WeekHeader?
    var sunday: NSDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // @todo move the setup to init?

        self.sunday = self.findPreviousSunday()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        var ypos:Float = 70.0
        let height:Float = 50.0
        
        let beginDate = sunday
        let endDate = sunday.nextDay(increment: 6)
        let header = WeekHeader.createHeader(height, cellWidth: self.view.bounds.width, beginDate: beginDate, endDate: endDate);
        header.backgroundColor = UIColor(red: 59/255, green: 173/255, blue: 255/255, alpha: 1.0)
        self.headerCell = header
        self.view.addSubview(header)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "hederSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        header.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "hederSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
        header.addGestureRecognizer(swipeLeft)

        var dayNum = self.sunday
        for day in self.daysOfWeek {
            var cell = RockerCell.createCell(day, cellHeight: height, cellWidth: self.view.bounds.width, cellY: ypos, day: dayNum.toRockerId())
            self.view.addSubview(cell)
            self.mileageCells += cell
            ypos = ypos + height
            dayNum = dayNum.nextDay()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*!
     * Handle the horizontal swiping of the date header.
     *
     * @param gesture
     *
     * @return void
     */
    func hederSwipe(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Left:
                self.sunday = sunday.nextDay(increment: 6)
                break;
            case UISwipeGestureRecognizerDirection.Right:
                self.sunday = sunday.prevDay(increment: 6)
                break;
            default:
                break;
            }
            
            let header = self.headerCell! as WeekHeader
            var date = sunday.nextDay()
            let endDate = date.nextDay(increment: 6)
            header.updateDate(date, endDate: endDate)
            for cell in self.mileageCells {
                cell.updateDate(date.toRockerId())
                date = date.nextDay()
            }
        }
    }
    
   
    /*!
     * Locate the most recent Sunday to find the beginning of this week.
     *
     * @return NSDate
     */
    func findPreviousSunday()->NSDate {
        let format = NSDateFormatter()
        format.dateFormat = "EEEE"
        let today = format.stringFromDate(0.days.fromNow)
        var day_count = 0
        while today != self.daysOfWeek[day_count] {
            day_count += 1
        }
        return day_count.days.fromNow
    }
    

}

