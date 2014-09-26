//
//  ViewController.swift
//  Runalysis
//
//  Created by Kevin Hankens on 7/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * Main view controller.
 */
class ViewController: UIViewController {
    
    // Tracks the Core Location Manager.
    var locationManager: CLLocationManager?
    
    var summaryView: WeekSummaryView?
   
    // The day to start on, defaults to localized Sunday.
    // @todo make the start configurable.
    var startOfWeek = 1
    
    // The day that the week ends on.
    var endOfWeek = 7
    
    // The array of days of the week.
    var daysOfWeek: [NSNumber] = [1,2,3,4,5,6,7]
    
    // Track the Sunday of the week we're currently viewing.
    var sunday: JLDate = JLDate.createFromDate(NSDate())
    
    // The scroll view container for this controller.
    var scrollView: UIScrollView?
    
    // The height of the content to scroll.
    var scrollContentHeight = CGFloat(0)
    
    // The current version, used to track intro/update modals.
    let version = 0.034
    
    // The position of cells that are off screen.
    let cellPosOffScreen = CGFloat(20)
    
    // Where the version is stored in the NSUserDefaults.
    let versionKey = "RunalysisVersion"
    
    // Tracks a background view that can be used for sub actions.
    var actionView: UIView?
    
    // Tracks the run button.
    var runButton: UIButton?
    
    // Tracks the "view latest" button.
    var latestButton: UIButton?
    
    // Tracks a route id that can be used when triggering a modal segue.
    var modalRouteId: NSNumber = 0
    
    // Tracks a JLDate that can be used when triggering a modal segue.
    var modalDayNum: JLDate?
    
    // If the view has been presented yet.
    var presented = false
    
    // Creates a shared RouteStore object to inject in others.
    let routeStore = RouteStore()
    
    // Creates a shared MileageStore object to inject in others.
    let mileageStore = MileageStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = UIScrollView(frame: CGRectMake(0, 20, self.view.frame.width, self.view.frame.height - 20))
        
        // @todo move the setup to init?
        
        // Locate the week we are on by finding the most recent Sunday.
        self.sunday = JLDate.createFromWeekStart(number: self.daysOfWeek[0])
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(20)
// BEGIN TEST SUMMARY
        
        let weekSummary = WeekSummaryView.createWeekSummaryView(CGRectMake(0, ypos, self.view.frame.width, self.view.frame.height/2), mileageStore: self.mileageStore, routeStore: self.routeStore, sunday: self.sunday, controller: self)
        self.summaryView = weekSummary
        container.addSubview(weekSummary)
        ypos += weekSummary.frame.height
        
        // Add a right swipe gesture.
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "changeDaySwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        container.addGestureRecognizer(swipeRight)
        
        // Add a left swipe gesture.
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "changeDaySwipe:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
        container.addGestureRecognizer(swipeLeft)
        
// END TEST SUMMARY
        
//        let height:CGFloat = 50.0
//        
//        let beginDate = self.sunday
//        let endDate = sunday.nextDay(increment: 6)
//        
//        let summary = SummaryCell.createCell(height * 1.75, cellWidth: self.view.bounds.width, cellY: ypos, beginDate: beginDate.date, endDate: endDate.date)
//        self.summaryCell = summary
//        
//        // Add a right swipe gesture to the header.
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: "headerSwipe:")
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//        summary.addGestureRecognizer(swipeRight)
//        
//        // Add a left swipe gesture to the header.
//        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "headerSwipe:")
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Left
//        summary.addGestureRecognizer(swipeLeft)
//        
//        // Start the rocker cells at the bottom of the summary.
//        ypos += summary.frame.height
//        
//        // Add a view behind the cells for hidden features.
//        let actions = UIView(frame: CGRect(x: 0, y: ypos, width: container.frame.width, height: container.frame.height - summary.frame.height))
//        self.actionView = actions
//        container.addSubview(actions)
//
//        // Add rocker cells for each day of the week.
//        var dayNum = self.sunday
//        var cell = RockerCell()
//        let format = NSDateFormatter()
//        format.dateFormat = "EEEE"
//        for day in self.daysOfWeek {
//            cell = RockerCell.createCell(dayNum.toStringDay(), cellHeight: height, cellWidth: self.view.bounds.width, cellY: self.cellPosOffScreen, day: dayNum, summary: summary, controller: self, store: self.mileageStore, routeStore: self.routeStore)
//            cell.finalY = ypos
//            //self.view.addSubview(cell)
//            self.mileageCells.append(cell)
//            ypos = ypos + height
//            dayNum = dayNum.nextDay()
//        }
//       
//        var i: Int
//        for (i = self.mileageCells.count - 1; i >= 0; i--) {
//            container.addSubview(self.mileageCells[i])
//        }
//        
//        // Track the mileage cells in the summary.
//        summary.cells = self.mileageCells
//        container.addSubview(summary)
//        self.updateSummary()
        
         // Add a Run button
        ypos += 10
        let runButton = UIButton()
        runButton.frame = CGRectMake(0, ypos, self.view.bounds.width/2, 35.00)
        runButton.setTitle("Run", forState: UIControlState.Normal)
        runButton.setTitleColor(GlobalTheme.getRunTextColor(), forState: UIControlState.Normal)
        runButton.titleLabel?.textAlignment = NSTextAlignment.Center
        runButton.backgroundColor = GlobalTheme.getBackgroundColor()
        runButton.addTarget(self, action: "displayRunViewFromButton:", forControlEvents: UIControlEvents.TouchDown)
        runButton.titleLabel?.font = UIFont.systemFontOfSize(30.0)
        self.runButton = runButton
        container.addSubview(runButton)
        
        // Add a Run button
        let latestButton = UIButton()
        latestButton.frame = CGRectMake(self.view.bounds.width/2, ypos, self.view.bounds.width/2, 35.00)
        latestButton.setTitle("Latest", forState: UIControlState.Normal)
        latestButton.setTitleColor(GlobalTheme.getRecentTextColor(), forState: UIControlState.Normal)
        latestButton.titleLabel?.textAlignment = NSTextAlignment.Center
        latestButton.backgroundColor = GlobalTheme.getBackgroundColor()
        latestButton.addTarget(self, action: "displayRouteViewFromButton:", forControlEvents: UIControlEvents.TouchDown)
        latestButton.titleLabel?.font = UIFont.systemFontOfSize(25.0)
        self.latestButton = latestButton
        container.addSubview(latestButton)
        
        self.scrollContentHeight = ypos + CGFloat(runButton.frame.height)
        self.scrollView = container
        self.view.addSubview(container)
        
        // Set up location manager.
        var lm = CLLocationManager()
        lm.desiredAccuracy = kCLLocationAccuracyBest
        // IOS7 does not respond.
        if lm.respondsToSelector(Selector("requestAlwaysAuthorization")) {
            lm.requestAlwaysAuthorization()
        }
        self.locationManager = lm
 
    }
    
    /*!
     * Implements UIViewController::viewWillAppear:animated
     */
    override func viewWillAppear(animated: Bool) {
        // Ensure that the UIScrollView knows its content bounds.
        if let container = self.scrollView? {
            container.contentSize = CGSizeMake(self.view.bounds.width, self.scrollContentHeight)
        }
    }
    
    /*!
     * Implements UIViewController::viewDidAppear:animated
     */
    override func viewDidAppear(animated: Bool) {
        // Display the cells and possibly the help page.
        if !self.presented {
            self.checkVersionChange()
            self.presented = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let v = segue.destinationViewController as? RouteViewController {
            v.routeStore = self.routeStore
            v.routeId = self.modalRouteId
        }
        else if let v = segue.destinationViewController as? NoteViewController {
            v.dayNum = self.modalDayNum
            v.routeStore = self.routeStore
            v.store = self.mileageStore
            v.routeId = self.modalRouteId
        }
        else if let v = segue.destinationViewController as? RunViewController {
            v.routeStore = self.routeStore
            v.routeId = self.modalRouteId
            v.locationManager = self.locationManager
        }
    }
    
    func launchRouteView() {
        self.performSegueWithIdentifier("routeViewSegue", sender: self)
    }
    
    func launchNoteView() {
        self.performSegueWithIdentifier("noteViewSegue", sender: self)
    }
    
    /*!
     * Handles the run button click.
     */
    func displayRunViewFromButton(button: UIButton) {
        self.performSegueWithIdentifier("runViewSegue", sender: self)
    }
    
    func displayRouteViewFromButton(button: UIButton) {
        if let id = self.routeStore.getLatestRouteId()? {
            self.modalRouteId = id
        }
        self.launchRouteView()
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
     * Respond to the help button click.
     *
     * @param UIButton sender
     *
     * @return void
     */
    func displayHelpViewFromButton(sender: UIButton) {
        self.displayHelpView()
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
            //self.displayHelpView()
        }
    }
    
    override func shouldAutorotate()->Bool {
      return false
    }
    
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientationMask.Portrait.toRaw())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*!
     * Update the header to reflect an updated week start value.
     *
     * @return void
     */
    func updateDay() {
        var date = self.sunday
        if let s = self.summaryView? {
            s.updateView(date)
        }
    }
    
    /*!
     * Handle the horizontal swiping to change date.
     *
     * @param gesture
     *
     * @return void
     */
    func changeDaySwipe(gesture: UIGestureRecognizer) {
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
            
            self.updateDay()
        }
    }

}

