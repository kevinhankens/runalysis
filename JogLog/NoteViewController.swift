//
//  NoteViewController.swift
//  JogLog
//
//  Created by Kevin Hankens on 9/20/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class NoteViewController: UIViewController {
    
    // The scroll view container for this controller.
    var scrollContainer: UIScrollView?
    
    // The height of the content to scroll.
    var scrollContentHeight = CGFloat(0)
 
    // The id of this route, which is a timestamp.
    var routeId: NSNumber = 0
    
    // Tracks the RouteStore object.
    var routeStore: RouteStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("\(self.routeId)")
        
        let container = UIScrollView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(30)
        
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(0, ypos, self.view.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchDown)
        container.addSubview(backButton)
        
        ypos = ypos + backButton.frame.height + 10
        
        self.scrollContentHeight = ypos
        self.scrollContainer = container
        self.view.addSubview(container)
    }
    
    /*!
    * Implements UIViewController::viewWillAppear:animated
    */
    override func viewWillAppear(animated: Bool) {
        if let container = self.scrollContainer? {
            container.contentSize = CGSizeMake(self.view.bounds.width, self.scrollContentHeight)
        }
    }
    
    
    /*!
     * Handles the button press to return to the root view.
     */
    func returnToRootView(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    override func shouldAutorotate()->Bool {
        return false
    }
    
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientation.Portrait.toRaw())
    }
    
}
