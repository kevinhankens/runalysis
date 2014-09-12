//
//  RouteViewController.swift
//  JogLog
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
class RouteViewController: UIViewController, UIScrollViewDelegate {
    
    // The id of this route, which is a timestamp.
    var routeId: NSNumber = 0
    
    // The storage of routes.
    var routeStore: RouteStore?
    
    var routeSummary: RouteSummary?
    
    // The currently viewed route.
    var routeView: RouteView?
    
    var routeAnalysisView: RouteAnalysisView?
    
    var dateLabel: UILabel?
    
    var distLabel: UILabel?
    
    var scrollContainer: UIScrollView?
    
    /*!
     * Overrides UIViewController::viewDidLoad()
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(30)
        
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(0, ypos, self.view.bounds.width, 20.00)
        backButton.setTitle("Back", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(backButton)
        
        ypos = ypos + backButton.frame.height + 10
        
        // Create a RouteView to display the results.
        let container = UIScrollView(frame: CGRectMake(0, ypos, self.view.bounds.width + 5, self.view.bounds.width))
        
        self.routeSummary = RouteSummary.createRouteSummary(self.routeId, routeStore: self.routeStore!)
        let routeView = RouteView.createRouteView(0, y: 0, width: self.view.bounds.width - 5, height: self.view.bounds.width - 5, routeId: self.routeId, routeStore: self.routeStore!, routeSummary: self.routeSummary!)
        
        // Add swipe gestures to change the route.
        let routeSwipeLeft = UISwipeGestureRecognizer(target: self, action: "routeSwipeGesture:")
        routeSwipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        routeView.addGestureRecognizer(routeSwipeLeft)
        
        let routeSwipeRight = UISwipeGestureRecognizer(target: self, action: "routeSwipeGesture:")
        routeSwipeRight.direction = UISwipeGestureRecognizerDirection.Right
        routeView.addGestureRecognizer(routeSwipeRight)
        
        // Scrolling
        container.minimumZoomScale = 1.0
        container.maximumZoomScale = 3.0
        container.contentSize = CGSizeMake(self.view.bounds.width, self.view.bounds.height)
        container.delegate = self
        
        self.routeView = routeView
        self.scrollContainer = container
        
        container.addSubview(routeView)
        self.view.addSubview(container)
        
        ypos = ypos + routeView.frame.height + 10
        
        // @todo what is the height of this view?
        let rav = RouteAnalysisView.createRouteAnalysisView(self.view.bounds.width, cellWidth: self.view.bounds.width, x: 0, y: ypos, routeSummary: self.routeSummary!)
        self.view.addSubview(rav)
        self.routeAnalysisView = rav

    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView!)->UIView! {
        return self.routeView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView!, withView view: UIView!, atScale scale: CGFloat) {
        if let rv = self.routeView as? RouteView {
            //let newRect = CGRectMake(rv.bounds.minX, rv.bounds.minY, rv.bounds.width, rv.bounds.height)
            //rv.setNeedsDisplayInRect(newRect)
            //rv.contentScaleFactor = scale
        }
        // @todo can we redraw at scale?
        //self.routeView!.setNeedsDisplay()
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
            
            // Update the ID of the route
            let next = self.routeStore!.getNextRouteId(self.routeId, prev: previous)
            
            if let r = next as? NSNumber {
                if let rv = self.routeView as? RouteView {
                    if let av = self.routeAnalysisView as? RouteAnalysisView {
                        self.routeId = r
                        self.routeSummary?.updateRoute(self.routeId)
                        // @todo set the route id in the summary here.
                        rv.updateRoute()
                        av.updateLabels()
                    }
                }
            }
        }
    }
    
    /*!
     * Handles the button press to return to the root view.
     */
    func returnToRootView(sender: UIButton) {
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
        return Int(UIInterfaceOrientation.Portrait.toRaw())
    }
    
    /*!
     *
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
