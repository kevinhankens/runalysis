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
    var summaryCell: SummaryCell?
    var sunday: NSDate = NSDate()
    var noteViewDayNum: NSNumber = 0
    var noteViewTriggeringCell: RockerCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // @todo move the setup to init?

        self.sunday = self.findPreviousSunday()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        var ypos:CGFloat = 125.0
        let height:CGFloat = 50.0
        
        let beginDate = sunday
        let endDate = sunday.nextDay(increment: 6)
        
        var summary = SummaryCell.createCell(height * 1.5, cellWidth: self.view.bounds.width, cellY: height - 10, beginDate: beginDate, endDate: endDate)
        self.summaryCell = summary
        
        self.view.addSubview(summary)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "headerSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        summary.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "headerSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
        summary.addGestureRecognizer(swipeLeft)

       
        var dayNum = self.sunday
        for day in self.daysOfWeek {
            var cell = RockerCell.createCell(day, cellHeight: height, cellWidth: self.view.bounds.width, cellY: ypos, day: dayNum.toRockerId(), summary: summary, controller: self)
            self.view.addSubview(cell)
            self.mileageCells += cell
            ypos = ypos + height
            dayNum = dayNum.nextDay()
        }
        
        summary.cells = self.mileageCells
        self.updateSummary()

    }
    
    func updateSummary() {
        let summary = self.summaryCell! as SummaryCell
        summary.updateValues()
        summary.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        let v = segue.destinationViewController as NoteViewController
        v.dayNum = self.noteViewDayNum
        v.triggeringCell = self.noteViewTriggeringCell
    }
    
    /*!
     * Handle the horizontal swiping of the date header.
     *
     * @param gesture
     *
     * @return void
     */
    func headerSwipe(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Left:
                self.sunday = sunday.nextDay(increment: 7)
                break;
            case UISwipeGestureRecognizerDirection.Right:
                self.sunday = sunday.prevDay(increment: 7)
                break;
            default:
                break;
            }
            
            let header = self.summaryCell! as SummaryCell
            //var date = sunday.nextDay()
            var date = sunday
            let endDate = date.nextDay(increment: 6)
            header.updateDate(date, endDate: endDate)
            for cell in self.mileageCells {
                cell.updateDate(date.toRockerId())
                date = date.nextDay()
            }
            
            self.updateSummary()
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

