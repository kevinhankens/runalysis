//
//  HelpView.swift
//  JogLog
//
//  Created by Kevin Hankens on 7/31/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class HelpView: UIView {
    
    // Tracks the parent view.
    var parent: UIView?

    /*!
     * Factory method to create a help view.
     *
     * @param UIView parent
     *
     * @return HelpView
     */
    class func createHelpView(parent: UIView)->HelpView {
        
        let container = HelpView(frame: CGRect(x: 0, y: 0, width: parent.bounds.width, height: parent.bounds.height))
        
        container.parent = parent
        
        container.backgroundColor = GlobalTheme.getOverlayBackgroundColor()
        
        // Content view.
        let content = UIView()
        
        let rockerHowto = UITextView(frame: CGRect(x: 0, y: 0, width: container.bounds.width - 15, height: 50.00))
        // @todo localize.
        rockerHowto.text = "Welcome to Jog Log! Swipe the date at the top of the screen to change the week then swipe each day to set your planned and actual mileage."
        rockerHowto.textColor = GlobalTheme.getNormalTextColor()
        rockerHowto.backgroundColor = GlobalTheme.getBackgroundColor()
        rockerHowto.sizeToFit()
        content.addSubview(rockerHowto)
        
        // Confirmation buttons.
        let bpos = rockerHowto.center.y + rockerHowto.frame.height/2 + 15
        let backButton = UIButton()
        backButton.frame = CGRectMake(5, bpos, container.bounds.width/2, 20.00)
        backButton.setTitle("Ok, got it!", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getPlannedColor()
        backButton.addTarget(container, action: "closeHelpView:", forControlEvents: UIControlEvents.TouchDown)
        backButton.layer.cornerRadius = 2;
        backButton.layer.borderWidth = 1;
        //backButton.layer.borderColor = GlobalTheme.getPlannedColor().CGColor
        content.addSubview(backButton)
        
        // Add some style and a frame to the content.
        content.layer.cornerRadius = 2
        content.layer.borderWidth = 1
        content.layer.borderColor = GlobalTheme.getActualColor().CGColor
        content.backgroundColor = GlobalTheme.getBackgroundColor()
        content.frame = CGRectMake(10, 150, container.bounds.width - 15, rockerHowto.frame.height + backButton.frame.height + 20)
        container.addSubview(content)
        
        return container
    }
    
    /*!
     * Closes this help view.
     *
     * @param UIButton sender
     *
     * @return void
     */
    func closeHelpView(sender: UIButton!) {
        self.removeFromSuperview()
    }
    
}