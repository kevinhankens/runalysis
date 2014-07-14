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
    
    var cover: UIView?
    var leftControl: UIView?
    var rightControl: UIView?
    var rocked: Bool?
    var rockedLeft: Bool?
    var rockedRight: Bool?

    //func init(frame: CGRect) {
    //    super.init(frame)
    //}
    
    class func createCell(centerText: String, cellHeight: Float, cellWidth: Float, cellY: Float)->RockerCell {
        // @todo cgrect size should be args
        // @todo make this 100% width
        let container = RockerCell(frame: CGRect(x: 0, y: cellY, width: cellWidth, height: 50.00))
        container.rockedLeft = false
        container.rockedRight = false
        
        // Create a control panel under the main visible cell.
        let leftControl = UIStepper(frame: CGRect(x: 3, y: 10, width: 30.00, height: 20.00))
        container.leftControl = leftControl
        container.addSubview(leftControl)
        
        let rightControl = UIStepper(frame: CGRect(x: cellWidth - 95, y: 10, width: 30.00, height: 20.00))
        container.rightControl = rightControl
        container.addSubview(rightControl)
        
        // Create a cover view.
        let cover = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: 50.00))
        cover.backgroundColor = UIColor.blackColor()
        container.cover = cover
        
        let leftLabel = UILabel(frame: CGRect(x: 3, y: 3, width: 50.00, height: 40.00))
        leftLabel.text = "0"
        leftLabel.textColor = container.getCoverTextColor()
        cover.addSubview(leftLabel)
        
        let centerLabel = UILabel(frame: CGRect(x: (cellWidth/2 - 50), y: 3, width: 100.00, height: 40.00))
        centerLabel.text = centerText
        centerLabel.textColor = container.getCoverTextColor()
        cover.addSubview(centerLabel)
        
        let rightLabel = UILabel(frame: CGRect(x: cellWidth - 50, y: 3, width: 100.00, height: 40.00))
        rightLabel.text = "0"
        rightLabel.textColor = container.getCoverTextColor()
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
    
    // Set the text color.
    func getCoverTextColor()->UIColor {
      return UIColor.whiteColor()
    }
    
    // Handles swipe gestures on the cover.
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            var v = gesture.view as RockerCell
            var c = v.cover!
            var f = c.frame
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                if v.rockedLeft! || !v.rockedRight! {
                  c.center = CGPointMake(c.center.x + 100, c.center.y)
                }
                if v.rockedLeft! {
                  v.rockedLeft = false
                }
                else {
                  v.rockedRight = true
                }
                break;
            case UISwipeGestureRecognizerDirection.Left:
                if v.rockedRight! || !v.rockedLeft! {
                    c.center = CGPointMake(c.center.x - 100, c.center.y)
                }
                if v.rockedRight! {
                    v.rockedRight = false
                }
                else {
                    v.rockedLeft = true
                }
                break;
            default:
                break;
            }
        }
    }

}
