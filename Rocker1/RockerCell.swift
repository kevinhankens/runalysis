//
//  RockerCell.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class RockerCell: UIView {

    // Tracks the sub views.
    var cover: UIView?
    var leftControl: UIView?
    var rightControl: UIView?
    var leftLabel: UIView?
    var rightLabel: UIView?

    // Tracks the position of the rocker.
    var rocked: Int = 0
    let rockedNone: Int = 0
    let rockedLeft: Int = -1
    let rockedRight: Int = 1
    
    class func createCell(centerText: String, cellHeight: Float, cellWidth: Float, cellY: Float)->RockerCell {
        // @todo cgrect size should be args
        // @todo make this 100% width
        let container = RockerCell(frame: CGRect(x: 0, y: cellY, width: cellWidth, height: 50.00))
        
        // Create a control panel under the main visible cell.
        let leftControl = RockerStepper(frame: CGRect(x: 3, y: 10, width: 30.00, height: 20.00))
        container.leftControl = leftControl
        leftControl.addTarget(container, action: "leftMileageIncrease:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(leftControl)
        
        let rightControl = RockerStepper(frame: CGRect(x: cellWidth - 95, y: 10, width: 30.00, height: 20.00))
        container.rightControl = rightControl
        rightControl.addTarget(container, action: "rightMileageIncrease:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(rightControl)
        
        // Create a cover view.
        let cover = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: 50.00))
        cover.backgroundColor = container.getCoverBgColorNormal()
        container.cover = cover
        
        let leftLabel = UILabel(frame: CGRect(x: 3, y: 3, width: 50.00, height: 40.00))
        leftLabel.text = "0"
        leftLabel.textColor = UIColor.whiteColor()
        leftLabel.layer.cornerRadius = 8
        leftLabel.layer.masksToBounds = true
        container.leftLabel = leftLabel
        cover.addSubview(leftLabel)
        
        let centerLabel = UILabel(frame: CGRect(x: (cellWidth/2 - 50), y: 3, width: 100.00, height: 40.00))
        centerLabel.text = centerText
        centerLabel.textColor = UIColor.whiteColor()
        cover.addSubview(centerLabel)
        
        let rightLabel = UILabel(frame: CGRect(x: cellWidth - 50, y: 3, width: 50.00, height: 40.00))
        rightLabel.text = "0"
        rightLabel.textColor = UIColor.whiteColor()
        rightLabel.layer.cornerRadius = 8
        rightLabel.layer.masksToBounds = true
        container.rightLabel = rightLabel
        cover.addSubview(rightLabel)
        
        // Swipe recognizer: right
        var swipeRight = UISwipeGestureRecognizer(target: container, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        container.addGestureRecognizer(swipeRight)
        
        // Swipe recognizer: left
        var swipeLeft = UISwipeGestureRecognizer(target: container, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        container.addGestureRecognizer(swipeLeft)
        container.addSubview(cover)
        
        return container
    }
    
    // Set the label normal color.
    func getCoverBgColorNormal()->UIColor {
      return UIColor(red: 42/255, green: 57/255, blue: 82/255, alpha: 1.0)
    }
    
    // Set the label highlight color.
    func getCoverBgColorHi()->UIColor {
        return UIColor(red: 28/255, green: 38/255, blue: 54/255, alpha: 1.0)
    }
    
    // Handles swipe gestures on the cover.
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            var v = gesture.view as RockerCell
            var c = v.cover!
            var f = c.frame
            var l = v.leftLabel! as UILabel
            var r = v.rightLabel! as UILabel
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if v.rocked == v.rockedLeft || v.rocked == v.rockedNone {
                    c.center = CGPointMake(c.center.x + 100, c.center.y)
                }
                if v.rocked == v.rockedNone {
                    l.backgroundColor = v.getCoverBgColorHi()
                    v.rocked = v.rockedRight
                }
                else {
                    r.backgroundColor = v.getCoverBgColorNormal()
                    v.rocked = v.rockedNone
                }
                break;
            case UISwipeGestureRecognizerDirection.Left:
                if v.rocked == v.rockedRight || v.rocked == v.rockedNone {
                    c.center = CGPointMake(c.center.x - 100, c.center.y)
                }
                if v.rocked == v.rockedNone {
                    r.backgroundColor = v.getCoverBgColorHi()
                    v.rocked = v.rockedLeft
                }
                else {
                    l.backgroundColor = v.getCoverBgColorNormal()
                    v.rocked = v.rockedNone
                }
                break;
            default:
                break;
            }
        }
    }
    
    // Handle stepper events
    func leftMileageIncrease(sender:UIStepper) {
        var v = self.leftLabel! as UILabel
        var fractionMiles = RockerStepper.mileageWithFraction(sender.value)
        v.text = "\(fractionMiles)"
    }
    
    // Handle stepper events
    func rightMileageIncrease(sender:UIStepper) {
        var v = self.rightLabel! as UILabel
        var fractionMiles = RockerStepper.mileageWithFraction(sender.value)
        v.text = "\(fractionMiles)"
    }

}
