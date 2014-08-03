//
//  ViewController.swift
//  JogLog
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
        let date = cal.dateByAddingComponents(self, toDate: NSDate.date(), options: nil)
        return date
    }
    
    // Locate a date prior to today.
    var beforeNow: NSDate {
        self.day *= -1
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
   
    // The day to start on, defaults to localized Sunday.
    // @todo make the start configurable.
    var startOfWeek = 1
    
    // The array of days of the week.
    var daysOfWeek = [1,2,3,4,5,6,7]
    
    // A list of the daily cells created.
    var mileageCells: [RockerCell] = []
    
    // The summary cell.
    var summaryCell: SummaryCell?
    
    // Track the Sunday of the week we're currently viewing.
    var sunday: NSDate = NSDate()
    
    // Track the note view in a modal.
    var noteViewDayNum: NSNumber = 0
    
    // Track the cell that triggered the note view modal.
    var noteViewTriggeringCell: RockerCell?
    
    // The current version, used to track intro/update modals.
    let version = 0.034
    
    // Where the version is stored in the NSUserDefaults.
    let versionKey = "JogLogVersion"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // @todo move the setup to init?
        // @todo move the date logic to a date object.
        
        // Locate the week we are on by finding the most recent Sunday.
        self.sunday = self.findWeekStartDate()
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let height:CGFloat = 50.0
        
        let beginDate = sunday
        let endDate = sunday.nextDay(increment: 6)
        
        let summary = SummaryCell.createCell(height * 1.5, cellWidth: self.view.bounds.width, cellY: height - 10, beginDate: beginDate, endDate: endDate)
        self.summaryCell = summary
        self.view.addSubview(summary)
        
        // Add a right swipe gesture to the header.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "headerSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        summary.addGestureRecognizer(swipeRight)
        
        // Add a left swipe gesture to the header.
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "headerSwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
        summary.addGestureRecognizer(swipeLeft)
        
        // Start the rocker cells at the bottom of the summary.
        var ypos:CGFloat = summary.frame.height + summary.frame.minY

        // Add rocker cells for each day of the week.
        var dayNum = self.sunday
        var cell = RockerCell()
        let format = NSDateFormatter()
        format.dateFormat = "EEEE"
        for day in self.daysOfWeek {
            var today = format.stringFromDate(dayNum)
            cell = RockerCell.createCell(today, cellHeight: height, cellWidth: self.view.bounds.width, cellY: ypos, day: dayNum.toRockerId(), summary: summary, controller: self)
            self.view.addSubview(cell)
            self.mileageCells += cell
            ypos = ypos + height
            dayNum = dayNum.nextDay()
        }
        
        // Track the mileage cells in the summary.
        summary.cells = self.mileageCells
        self.updateSummary()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.checkVersionChange()
    }
    
    /*!
     * Displays a help view depending upon version changes.
     *
     * @return void
     */
    func displayHelpView() {
        self.view.addSubview(HelpView.createHelpView(self.view))
    }
    
    /*!
     * Removes the help view from the screen if it is displayed.
     *
     * @return void
     */
    func closeHelpView() {
        for v in self.view.subviews {
            if let hv = v as? HelpView {
                hv.removeFromSuperview()
            }
        }
    }
    
    /*!
     * Checks the recent version of the UI and displays a help view for new versions.
     *
     * @return void
     */
    func checkVersionChange() {
        let recentVersion = NSUserDefaults.standardUserDefaults().doubleForKey(self.versionKey)
        
        // On version changes, track the latest updated.
        if recentVersion < self.version {
            NSUserDefaults.standardUserDefaults().setDouble(self.version, forKey: self.versionKey)
            NSUserDefaults.standardUserDefaults().synchronize()
            self.displayHelpView()
        }
    }
    
    override func shouldAutorotate()->Bool {
      return false
    }
    
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientation.Portrait.toRaw())
    }
    
    /*!
     * Updates the associated summary cell to use the most recent values.
     *
     * @return void
     */
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
        // @todo put identifiers into properties
        if segue.identifier == "noteViewSegue" {
            let v = segue.destinationViewController as NoteViewController
            v.dayNum = self.noteViewDayNum
            v.triggeringCell = self.noteViewTriggeringCell
        }
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
    func findWeekStartDate()->NSDate {
        let format = NSDateFormatter()
        format.dateFormat = "c"
        let today = format.stringFromDate(NSDate()).toInt()
        var day_count = 0
        for i in self.daysOfWeek {
            if today == self.daysOfWeek[day_count] {
                break
            }
            else {
                day_count++
            }
        }
        return day_count.days.beforeNow
    }
    

}

