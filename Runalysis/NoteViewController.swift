//
//  NoteViewController.swift
//  Runalysis
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
    
    // The core data storage for mileage.
    var dayNum: JLDate?
    
    // The core data storage for mileage.
    var store: MileageStore?
    
    // Tracks the RouteStore object.
    var routeStore: RouteStore?
    
    var noteView: NoteView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = UIScrollView(frame: CGRectMake(0, 20, self.view.frame.width, self.view.frame.height - 20))
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(20)
        
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(0, ypos, self.view.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.titleLabel?.font = UIFont.systemFontOfSize(30.0)
        backButton.titleLabel?.textAlignment = NSTextAlignment.Left
        backButton.setTitleColor(GlobalTheme.getBackButtonTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchDown)
        container.addSubview(backButton)
        
        ypos = ypos + backButton.frame.height + 10
        
        if let routeStore = self.routeStore? {
            if let mileageStore = self.store? {
                if let dayNum = self.dayNum? {
                    let n = NoteView.createNoteView(0, y: ypos, width: self.view.bounds.width - 20, height: self.view.bounds.height, dayNum: self.dayNum!, mileageStore: mileageStore, routeStore: self.routeStore!)
                    container.addSubview(n)
                    self.noteView = n
                }
            }
        }
        
        self.scrollContentHeight = ypos
        self.scrollContainer = container
        self.view.addSubview(container)
    }
    
    /*!
    * Implements UIViewController::viewWillAppear:animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let container = self.scrollContainer? {
            container.contentSize = CGSizeMake(self.view.bounds.width, self.scrollContentHeight)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let n = self.noteView? {
            if let textview = n.note? {
                textview.becomeFirstResponder()
            }
        }
    }
    
    /*!
     * Handles the button press to return to the root view.
     */
    func returnToRootView(sender: UIButton) {
        if let n = self.noteView? {
            if let textview = n.note? {
                textview.endEditing(true)
                n.saveNote()
                textview.resignFirstResponder()
            }
        }
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func shouldAutorotate()->Bool {
        return false
    }
    
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientationMask.Portrait.toRaw())
        //return Int(UIInterfaceOrientation.Portrait.toRaw())
    }
    
}
