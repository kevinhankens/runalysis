//
//  ViewController.swift
//  JogLog
//
//  Created by Kevin Hankens on 7/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import UIKit

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
    var sunday: JLDate = JLDate.createFromDate(NSDate())
    
    // Track the note view in a modal.
    // @todo poor variable name.
    var noteViewDayNum: JLDate = JLDate.createFromDate(NSDate())
    
    // Track the cell that triggered the note view modal.
    var noteViewTriggeringCell: RockerCell?
    
    // The current version, used to track intro/update modals.
    let version = 0.034
    
    // Where the version is stored in the NSUserDefaults.
    let versionKey = "JogLogVersion"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // @todo move the setup to init?
        
        // Locate the week we are on by finding the most recent Sunday.
        self.sunday = JLDate.createFromWeekStart(number: self.daysOfWeek[0])
        
        self.view.backgroundColor = UIColor.blackColor()
        
        let height:CGFloat = 50.0
        
        let beginDate = self.sunday
        let endDate = sunday.nextDay(increment: 6)
        
        let summary = SummaryCell.createCell(height * 1.5, cellWidth: self.view.bounds.width, cellY: height - 10, beginDate: beginDate.date, endDate: endDate.date)
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
            cell = RockerCell.createCell(dayNum.toStringDay(), cellHeight: height, cellWidth: self.view.bounds.width, cellY: ypos, day: dayNum, summary: summary, controller: self, store: nil)
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
            var date = sunday
            let endDate = date.nextDay(increment: 6)
            // @todo update summary to use JLDate
            header.updateDate(date.date, endDate: endDate.date)
            for cell in self.mileageCells {
                cell.updateDate(date)
                date = date.nextDay()
            }
            
            self.updateSummary()
        }
    }

}

