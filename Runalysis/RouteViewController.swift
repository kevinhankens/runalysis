//
//  RouteViewController.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/18/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * The "route" view controller is our method for displaying the results of
 * an event. We can use this to scroll through routes and view details via
 * RootView objects. In retrospect, "route view" is a terrible name.
 */
class RouteViewController: UIViewController, UIAlertViewDelegate {
    
    // The id of this route, which is a timestamp.
    var routeId: NSNumber = 0
    
    // Tracks the RouteStore object.
    var routeStore: RouteStore?
    
    // Tracks the RouteSummary object.
    var routeSummary: RouteSummary?
    
    // The currently viewed route.
    var routeView: RouteView?
    
    // The route layer drawing.
    var routeLayer: CALayer?
    
    // Tracks the RouteAnalysisView object.
    var routeAnalysisView: RouteAnalysisView?
    
    // Tracks the label with the current date.
    var dateLabel: UILabel?
    
    // Tracks the label with the current distance.
    var distLabel: UILabel?
    
    // Tracks a label that denotes a loading route.
    var loadingLabel: UILabel?
    
    // Tracks the container for scrolling/zooming.
    var scrollContainer: UIScrollView?
    
    // The height of the content to scroll.
    var scrollContentHeight = CGFloat(0)
    
    // Tracks the height of the RouteAnalysisView.
    var ravHeight = CGFloat(0)
    
    // Tracks that a delete action was triggered.
    var deleteTriggered = false
    
    // Tracks the timer that controls the route drawing.
    var drawTimer: NSTimer = NSTimer()
    
    // Tracks which step the drawing animation is on.
    var drawStep: Int = 0
    
    // Tracks how many steps are in the drawing animation.
    var drawSteps: Int = 0
    
    /*!
     * Overrides UIViewController::viewDidLoad()
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = UIScrollView(frame: CGRectMake(0, 20, self.view.frame.width, self.view.frame.height - 20))
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(50)

        // Create a RouteView to display the results.
        //let container = UIScrollView(frame: CGRectMake(0, ypos, self.view.bounds.width + 5, self.view.bounds.width))
        
        self.routeSummary = RouteSummary.createRouteSummary(self.routeId, routeStore: self.routeStore!)
        let routeView = RouteView.createRouteView(0, y: ypos, width: self.view.bounds.width - 5, height: self.view.bounds.width - 5, routeId: self.routeId, routeStore: self.routeStore!, routeSummary: self.routeSummary!)
        
        // Add swipe gestures to change the route.
        let routeSwipeLeft = UISwipeGestureRecognizer(target: self, action: "routeSwipeGesture:")
        routeSwipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        container.addGestureRecognizer(routeSwipeLeft)
        
        let routeSwipeRight = UISwipeGestureRecognizer(target: self, action: "routeSwipeGesture:")
        routeSwipeRight.direction = UISwipeGestureRecognizerDirection.Right
        container.addGestureRecognizer(routeSwipeRight)
        
        let press = UILongPressGestureRecognizer(target: self, action: "routeDeleteGesture:")
        container.addGestureRecognizer(press)
        
        // Scrolling
        //container.minimumZoomScale = 1.0
        //container.maximumZoomScale = 3.0
        //container.contentSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        //container.delegate = self
        
        let routeLayer = CALayer()
        routeLayer.delegate = routeView
        routeLayer.frame = routeView.frame
        container.layer.addSublayer(routeLayer)
        
        self.drawRoute()
        
        self.routeLayer = routeLayer
        self.routeView = routeView
        
        container.addSubview(routeView)
        
        // Add left/right arrows.
        let leftArrowLabel = UILabel(frame: CGRect(x: 10, y: ypos + routeView.frame.maxY/2, width: 20, height: 30))
        leftArrowLabel.text = "<"
        leftArrowLabel.font = UIFont.systemFontOfSize(30)
        leftArrowLabel.textColor = GlobalTheme.getNormalTextColor()
        leftArrowLabel.textAlignment = NSTextAlignment.Left
        container.addSubview(leftArrowLabel)
        
        let rightArrowLabel = UILabel(frame: CGRect(x: container.frame.maxX - 30, y: ypos + routeView.frame.maxY/2, width: 20, height: 30))
        rightArrowLabel.text = ">"
        rightArrowLabel.font = UIFont.systemFontOfSize(30)
        rightArrowLabel.textColor = GlobalTheme.getNormalTextColor()
        rightArrowLabel.textAlignment = NSTextAlignment.Left
        container.addSubview(rightArrowLabel)
        
        ypos = ypos + routeView.frame.height + 10
        
        // @todo what is the height of this view?
        let rav = RouteAnalysisView.createRouteAnalysisView(80.0, cellWidth: self.view.bounds.width, x: 0, y: ypos, routeSummary: self.routeSummary!)
        container.addSubview(rav)
        self.routeAnalysisView = rav
        
        self.ravHeight = rav.frame.height + 10
        
        self.scrollContentHeight = ypos + 20 // + CGFloat(rav.frame.height)
        self.scrollContainer = container
        self.view.addSubview(container)
       
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(10, 30, self.view.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.titleLabel?.sizeToFit()
        backButton.titleLabel?.font = UIFont.systemFontOfSize(30.0)
        backButton.titleLabel?.textAlignment = NSTextAlignment.Left
        backButton.setTitleColor(GlobalTheme.getBackButtonTextColor(), forState: UIControlState.Normal)
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        backButton.backgroundColor = GlobalTheme.getBackButtonBgColor()
        backButton.addTarget(self, action: "returnToRootViewButton:", forControlEvents: UIControlEvents.TouchDown)
        backButton.sizeToFit()
        self.view.addSubview(backButton)
        
        
    }
    
    /*!
     * Draws the route in the currently loaded summary.
     */
    func drawRoute() {
        if let points = self.routeSummary?.points {
            
            self.drawSteps = points.count/50
            self.drawStep = 0
            self.drawTimer = NSTimer.scheduledTimerWithTimeInterval(0.025, target: self, selector: Selector("drawRouteAnimated"), userInfo: nil, repeats: true)
        }
    }
    
    /*!
     * NSTimer callback to draw the route a bit at a time.
     */
    func drawRouteAnimated() {
        self.drawStep++
        self.routeSummary!.animation_length = self.drawStep * self.drawSteps
        self.routeLayer!.setNeedsDisplay()
        
        if self.routeSummary!.animation_length > self.routeSummary!.points!.count {
            self.drawTimer.invalidate()
        }
    }
    
    /*!
    * Implements UIViewController::viewWillAppear:animated
    */
    override func viewWillAppear(animated: Bool) {
        self.resetContentHeight()
    }
    
    // Sets the height of the scrollview container based on the contents.
    func resetContentHeight() {
        if let container = self.scrollContainer? {
            container.contentSize = CGSizeMake(self.view.bounds.width, self.scrollContentHeight + self.ravHeight + 30)
        }
    }
    
    /*!
     * UIScrollViewDelegate
     */
    func viewForZoomingInScrollView(scrollView: UIScrollView!)->UIView! {
        return self.routeView
    }
    
    /*!
     * UIScrollViewDelegate
     */
    func scrollViewDidEndZooming(scrollView: UIScrollView!, withView view: UIView!, atScale scale: CGFloat) {
        if let rv = self.routeView? {
            //let newRect = CGRectMake(rv.bounds.minX, rv.bounds.minY, rv.bounds.width, rv.bounds.height)
            //rv.setNeedsDisplayInRect(newRect)
            //rv.contentScaleFactor = scale
        }
        // @todo can we redraw at scale?
        //self.routeView!.setNeedsDisplay()
    }
    
    /**
     * Catch a gesture to delete the current route.
     *
     * @param UILongPressGestureRecognizer gesture
     *
     * @return void
     */
    func routeDeleteGesture(gesture: UILongPressGestureRecognizer) {
        if self.routeId == 0 {
            return
        }
        // Long presses can trigger multiple calls.
        if (gesture.state == UIGestureRecognizerState.Began) {
            self.deleteTriggered = false
        }
        if !self.deleteTriggered {
            self.deleteTriggered = true
            let alert = UIAlertView(title: "Delete Route?", message: "You are about to permanently delete this route.", delegate: nil, cancelButtonTitle: "Cancel")
            alert.addButtonWithTitle("Delete")
            alert.delegate = self
            alert.show()
        }
    }
    
    /**
     * UIAlertViewDelegate::alertView(clickedButtonAtIndex: buttonIndex)
     */
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.routeStore?.deleteRoute(self.routeId)
            self.displayNextRoute(false, force: true)
        }
    }
    
    /*!
     * Handles the swipe gestures on a RouteView.
     *
     * @param UIGestureRecognizer gesture
     */
    func routeSwipeGesture(gesture: UIGestureRecognizer) {
        if let g = gesture as? UISwipeGestureRecognizer {
            var previous = false
            
            var id = self.routeId
            switch g.direction {
            case UISwipeGestureRecognizerDirection.Left:
                // Left swipes show newer routes.
                previous = false
                break;
            case UISwipeGestureRecognizerDirection.Right:
                // Right swipes show older routes.
                previous = true
                break;
            default:
                break;
            }
            
            self.displayNextRoute(previous)
        }
    }
    
    /*!
     * Displays the next or previous route.
     *
     * @param Bool previous
     * @param Bool force
     */
    func displayNextRoute(previous: Bool, force: Bool = false) {
        
        // Update the ID of the route
        let next = self.routeStore!.getNextRouteId(self.routeId, prev: previous)
        
        if let r = next? {
            if let rv = self.routeView? {
                if let rav = self.routeAnalysisView? {
                    self.routeId = r
                    self.routeSummary?.updateRoute(self.routeId)
                    // @todo set the route id in the summary here.
                    rv.updateRoute()
                    rav.updateLabels()
                    self.ravHeight = rav.frame.height
                    rav.updateDuration(self.routeSummary!.duration)
                    self.resetContentHeight()
                    //self.routeLayer?.setNeedsDisplay()
                    self.drawRoute()
                }
            }
        }
        else {
            // If there is no "next" try the other direction. If there is
            // nothing, return to the root view.
            // @todo make this circular, only return if there are no routes.
            let next = self.routeStore!.getNextRouteId(self.routeId, prev: !previous)
            if let r = next? {
                if force {
                    self.displayNextRoute(!previous, force: force)
                }
            }
            else if force {
                self.returnToRootView()
            }
        }
    }
    
    /*!
     * Handles the button press to return to the root view.
     */
    func returnToRootViewButton(sender: UIButton) {
        self.returnToRootView()
    }
    
    /*!
     * Dismisses this view controller to return to the root view.
     */
    func returnToRootView() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*!
     *
     */
    override func shouldAutorotate()->Bool {
        return false
    }
    
    /*!
     *
     */
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    /*!
     *
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
