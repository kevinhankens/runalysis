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
class RouteViewController: UIViewController {
    
    // The id of this route, which is a timestamp.
    var routeId: NSNumber = 0
    
    // The storage of routes.
    var routeStore: RouteStore?
    
    // The currently viewed route.
    var routeView: RouteView?
    
    var dateLabel: UILabel?
    
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
        let routeView = RouteView.createRouteView(0, y: ypos, width: self.view.bounds.width, height: self.view.bounds.width, routeId: self.routeId, routeStore: self.routeStore!)
        
        // Add swipe gestures to change the route.
        let routeSwipeLeft = UISwipeGestureRecognizer(target: self, action: "routeSwipeGesture:")
        routeSwipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        routeView.addGestureRecognizer(routeSwipeLeft)
        
        let routeSwipeRight = UISwipeGestureRecognizer(target: self, action: "routeSwipeGesture:")
        routeSwipeRight.direction = UISwipeGestureRecognizerDirection.Right
        routeView.addGestureRecognizer(routeSwipeRight)
        self.routeView = routeView
        
        self.view.addSubview(routeView)
        
        ypos = ypos + routeView.frame.height + 40
        
        let dl = UILabel(frame: CGRectMake(10, ypos, self.view.bounds.width, 20))
        dl.text = "-"
        dl.textColor = GlobalTheme.getNormalTextColor()
        self.dateLabel = dl
        self.updateDateLabel()
        
        self.view.addSubview(dl)
    }
    
    func updateDateLabel() {
        if let dl = self.dateLabel as? UILabel {
            let date = NSDate(timeIntervalSince1970:self.routeId)
            let format = NSDateFormatter()
            format.dateFormat = JLDate.getDateFormatFull()
            dl.text = format.stringFromDate(date)
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
            
            // Update the ID of the route
            let next = self.routeStore!.getNextRouteId(self.routeId, prev: previous)
            
            if let r = next as? NSNumber {
                if let rv = self.routeView as? RouteView {
                    self.routeId = r
                    rv.changeRoute(r)
                    self.updateDateLabel()
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
