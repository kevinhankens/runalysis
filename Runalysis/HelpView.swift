//
//  HelpView.swift
//  Runalysis
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
        
        var ypos = CGFloat(10)
        
         // Content view.
        let content = UIView()
        
        let iconSize = CGFloat(36)
        let runalysisImage = UIImage(named: "RunalysisButton")
        let icon = UIImageView(image: runalysisImage)
        icon.frame = CGRectMake(10, ypos, iconSize, iconSize)
        content.addSubview(icon)
        
        ypos += icon.frame.height + 10
       
        let rockerHowto = UITextView(frame: CGRect(x: 20, y: ypos, width: container.bounds.width - 50, height: container.bounds.width))
        // @todo localize.
        rockerHowto.font = GlobalTheme.getNormalFont()
        rockerHowto.text = "Tap a day to set your goal/actual running mileage.\n\nTap Run to track your workout.\n\nTap Latest to view your most recent runs.\n\nSwipe sideways on any page to change the date."
        rockerHowto.editable = false
        rockerHowto.textColor = GlobalTheme.getNormalTextColor()
        rockerHowto.backgroundColor = GlobalTheme.getBackgroundColor()
        rockerHowto.sizeToFit()
        content.addSubview(rockerHowto)
        
        ypos += rockerHowto.frame.height + 20
        
        // Confirmation buttons.
        let backButton = UIButton()
        backButton.frame = CGRectMake(20, ypos, container.bounds.width/2, 20.00)
        backButton.setTitle("Ok, got it!", forState: UIControlState.Normal)
        backButton.titleLabel?.sizeToFit()
        backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        backButton.setTitleColor(GlobalTheme.getRunTextColor(), forState: UIControlState.Normal)
        backButton.titleLabel!.font = UIFont.systemFontOfSize(25.0)
        backButton.addTarget(container, action: "closeHelpView:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.sizeToFit()
        content.addSubview(backButton)
        
        ypos += backButton.frame.height + 30
        
        // Add some style and a frame to the content.
        content.backgroundColor = GlobalTheme.getBackgroundColor()
        content.frame = CGRectMake(10, (container.bounds.height - ypos)/2, container.bounds.width - 20, ypos)
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
