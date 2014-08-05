//
//  RockerCell.swift
//  JogLog
//
//  Created by Kevin Hankens on 7/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * @class RockerCell
 *
 * Creates a view with hidden controls on either side accessed by horizontal swipe.
 */
class RockerCell: UIView {

    // The cover view which contains the labels.
    var cover: UIView?
   
    // The boundaries of the left pan.
    var coverBoundsLeft = CGFloat(0)
    
    // The boundaries of the right pan.
    var coverBoundsRight = CGFloat(0)
    
    // The "normal" home position of the cover.
    var coverBoundsNormal = CGFloat(0)
    
    // The Limit to the cover movement.
    var coverBoundsOffset = CGFloat(100)
    
    // The left-hand stepper.
    var leftControl: UIView?
    
    // The right-hand stepper.
    var rightControl: UIView?
    
    // The left-hand label.
    var leftLabel: UIView?
    
    // The right-hand label.
    var rightLabel: UIView?
    
    // The identifier of the day, e.g. 20140715
    // @todo convert to JLDate?
    var dayNum: NSNumber = 0
    
    // The core data storage.
    var store: MileageStore = MileageStore()
    
    // The position of the rocker.
    var rocked: Int = 0
    
    // The rocker is not moved.
    let rockedNone: Int = 0
    
    // The rocker is moved left (exposed on the right).
    let rockedLeft: Int = -1
    
    // The rocker is moved right (exposed on the left).
    let rockedRight: Int = 1
    
    // Tracks the summary cell to update when mileages change.
    var summary: SummaryCell?
    
    // Tracks the parent controller to trigger note view segue.
    var controller: UIViewController?
    
    /*!
     * Factory method to create an instance of RockerCell
     *
     * @param centerText
     * @param cellHeight
     * @param cellWidth
     * @param cellY
     * @param day
     *
     * @return RockerCell
     */
    class func createCell(centerText: String, cellHeight: CGFloat, cellWidth:
        CGFloat, cellY: CGFloat, day: NSNumber, summary: SummaryCell?, controller: UIViewController?, store: MileageStore?)->RockerCell {
        // @todo cgrect size should be args
        // @todo make this 100% width
        // @todo make the steppers injectable?
           
        let container = RockerCell(frame: CGRectMake(0, cellY, cellWidth, 50.00))
        container.dayNum = day
            
        if let st = store as? MileageStore {
            container.store = st
        }
            
        let leftBg = UIView(frame: CGRect(x: 0, y: 0, width: container.bounds.width/2, height: container.bounds.height))
        leftBg.backgroundColor = GlobalTheme.getPlannedColor()
        container.addSubview(leftBg)
            
        let rightBg = UIView(frame: CGRect(x: container.bounds.width/2, y: 0, width: container.bounds.width/2, height: container.bounds.height))
        rightBg.backgroundColor = GlobalTheme.getActualColor()
        container.addSubview(rightBg)
            
        container.summary = summary
            
        container.controller = controller
            
        let mileageData = container.store.getMileageForDate(day)
        
        // Create a control panel under the main visible cell.
        let leftControl = RockerStepper(frame: CGRect(x: 3, y: 10, width: 30.00, height: 20.00))
        container.leftControl = leftControl
        leftControl.addTarget(container, action: "leftMileageIncrease:", forControlEvents: UIControlEvents.ValueChanged)
        leftControl.addTarget(container, action: "leftMileageSave:", forControlEvents: UIControlEvents.TouchUpInside)
        leftControl.value = Double(mileageData.mileagePlanned)
        leftControl.tintColor = UIColor.whiteColor()
        container.addSubview(leftControl)
        
        let rightControl = RockerStepper(frame: CGRect(x: cellWidth - 95, y: 10, width: 30.00, height: 20.00))
        container.rightControl = rightControl
        rightControl.addTarget(container, action: "rightMileageIncrease:", forControlEvents: UIControlEvents.ValueChanged)
        rightControl.addTarget(container, action: "rightMileageSave:", forControlEvents: UIControlEvents.TouchUpInside)
        rightControl.value = Double(mileageData.mileageActual)
        rightControl.tintColor = UIColor.whiteColor()
        container.addSubview(rightControl)
        
        // Create a cover view.
        let cover = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: 50.00))
        cover.backgroundColor = container.getCoverBgColorNormal()
        container.cover = cover
        container.coverBoundsNormal = cover.center.x
        
        let leftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50.00, height: container.bounds.height))
        leftLabel.text = RockerStepper.getLabel(Double(mileageData.mileagePlanned))
        leftLabel.textColor = GlobalTheme.getPlannedColor()
        leftLabel.textAlignment = NSTextAlignment.Center
        container.leftLabel = leftLabel
        cover.addSubview(leftLabel)
        container.coverBoundsLeft = cover.center.x - container.coverBoundsOffset
        
        let centerLabel = UILabel(frame: CGRect(x: (cellWidth/2 - 50), y: 3, width: 100.00, height: 40.00))
        centerLabel.text = centerText
        centerLabel.sizeToFit()
        centerLabel.textColor = GlobalTheme.getNormalTextColor()
        centerLabel.textAlignment = NSTextAlignment.Center
        centerLabel.frame = CGRectMake((container.frame.width/2 - centerLabel.frame.width/2), (container.frame.height/2 - centerLabel.frame.height/2), centerLabel.frame.width, centerLabel.frame.height)
        cover.addSubview(centerLabel)
        
        let rightLabel = UILabel(frame: CGRect(x: cellWidth - 50, y: 0, width: 50.00, height: container.bounds.height))
        rightLabel.text = RockerStepper.getLabel(Double(mileageData.mileageActual))
        rightLabel.textColor = GlobalTheme.getActualColor()
        rightLabel.textAlignment = NSTextAlignment.Center
        container.rightLabel = rightLabel
        cover.addSubview(rightLabel)
        container.coverBoundsRight = cover.center.x + container.coverBoundsOffset
        
        // Pan gesture recognizer.
        let pan = UIPanGestureRecognizer(target: container, action: "respondToPanGesture:")
        container.addGestureRecognizer(pan)
            
        // Tap gesture recognizer.
        let tap = UITapGestureRecognizer(target: container, action: "respondToTapGesture:")
        tap.numberOfTapsRequired = 2
        cover.addGestureRecognizer(tap)
        
        container.addSubview(cover)
        
        return container
    }
    
    /*!
     * Gets the label background highlight color.
     *
     * @return UIColor
     */
    func getCoverBgColorNormal()->UIColor {
        return UIColor.blackColor()
    }
    
    /*!
     * Gets the label background highlight color.
     *
     * @return UIColor
     */
    func getCoverBgColorHi()->UIColor {
        return UIColor(red: 69/255, green: 173/255, blue: 125/255, alpha: 1.0)
        //return UIColor(red: 59/255, green: 173/255, blue: 255/255, alpha: 1.0)
    }
    
    /*!
     * Handle taps on the rocker cover.
     *
     * @param UITapGestureRecognizer tap
     */
    func respondToTapGesture(tap: UITapGestureRecognizer) {
        if let c = self.controller as? ViewController {
            c.noteViewDayNum = self.dayNum
            c.noteViewTriggeringCell = self
            c.performSegueWithIdentifier("noteViewSegue", sender: c)
        }
    }
   
    /*!
     * Handle the pan gesture of the rocker cell cover.
     *
     * @param UIPanGestureRecognizer pan
     *
     * @return void
     */
    func respondToPanGesture(pan: UIPanGestureRecognizer) {
        var v = pan.view as RockerCell
        var c = v.cover! as UIView
        var translation = pan.translationInView(c.superview) as CGPoint
        var pos = c.center as CGPoint
        
        // Move the cover horizontally based on the pan change.
        if (c.center.x >= v.coverBoundsLeft && c.center.x <= v.coverBoundsRight) {
            pos.x += translation.x
            c.center = pos
            pan.setTranslation(CGPointZero, inView: cover)
        }
        
        // Define some boundaries and react to incomplete pans.
        if (pan.state == UIGestureRecognizerState.Ended) {
            if (c.center.x <= v.coverBoundsLeft) {
                // Don't allow it to go beyond the left boundary.
                c.center.x = v.coverBoundsLeft
            }
            else if (c.center.x >= v.coverBoundsRight) {
                // Don't allow it to go beyond the right boundary.
                c.center.x = v.coverBoundsRight
            }
            else if (c.center.x > v.coverBoundsNormal && c.center.x <= v.coverBoundsNormal + (v.coverBoundsOffset/2)) {
                // Snap to center if they are right of normal and left of half.
                UIView.animateWithDuration(0.1, animations: {
                    c.center.x = v.coverBoundsNormal
                    })
            }
            else if (c.center.x < v.coverBoundsRight && c.center.x > v.coverBoundsNormal + (v.coverBoundsOffset/2)) {
                // Snap to right if they are right of the half.
                UIView.animateWithDuration(0.1, animations: {
                    c.center.x = v.coverBoundsRight
                    })
            }
            else if (c.center.x < v.coverBoundsNormal && c.center.x >= v.coverBoundsNormal - (v.coverBoundsOffset/2)) {
                // Snap to center if they are left of normal and right of half.
                UIView.animateWithDuration(0.1, animations: {
                    c.center.x = v.coverBoundsNormal
                    })
            }
            else if (c.center.x > v.coverBoundsLeft && c.center.x < v.coverBoundsNormal - (v.coverBoundsOffset/2)) {
                // Snap to left if they are left of the half.
                UIView.animateWithDuration(0.1, animations: {
                    c.center.x = v.coverBoundsLeft
                    })
            }
        }
    }
   
    /*!
     * Update the date of a cell.
     *
     * @param NSNumber day
     *
     * @return void.
     */   
    func updateDate(day: NSNumber) {
        let mileageData = self.store.getMileageForDate(day)
        let lc = self.leftControl! as UIStepper
        let ll = self.leftLabel! as UILabel
        let rc = self.rightControl! as UIStepper
        let rl = self.rightLabel! as UILabel
        
        self.dayNum = day
        lc.value = Double(mileageData.mileagePlanned)
        ll.text = RockerStepper.getLabel(lc.value)
        rc.value = Double(mileageData.mileageActual)
        rl.text = RockerStepper.getLabel(rc.value)
    }
    
    /*!
     * Handle the left stepper value change.
     *
     * @param UIStepper sender
     *
     * @return void.
     */
    func leftMileageIncrease(sender:UIStepper) {
        var v = self.leftLabel! as UILabel
        var fractionMiles = RockerStepper.getLabel(sender.value)
        v.text = "\(fractionMiles)"
    }
    
    /*!
     * Handle the right stepper value change.
     *
     * @param UIStepper sender
     *
     * @return void.
     */
    func rightMileageIncrease(sender:UIStepper) {
        var v = self.rightLabel! as UILabel
        var fractionMiles = RockerStepper.getLabel(sender.value)
        v.text = "\(fractionMiles)"
    }
    
    /*!
     * Saves the mileage currently set on this object.
     *
     * @return void.
     */
    func saveMileage() {
        let l = self.leftControl! as UIStepper
        let r = self.rightControl! as UIStepper
        self.store.setMileageForDay(self.dayNum, planned: l.value, actual: r.value, note: "")
        self.store.saveContext()
        
        if let summary = self.summary as? SummaryCell {
            summary.updateValues()
            summary.setNeedsDisplay()
        }
        
        //println("SAVED: \(self.dayNum) L: \(l.value) R: \(r.value)")
    }
    
    /*!
     * Handle the left stepper touch release.
     *
     * @param UIStepper sender
     *
     * @return void.
     */
    func leftMileageSave(sender:UIStepper) {
        self.saveMileage()
    }
    
    /*!
     * Handle the left stepper touch release.
     *
     * @param UIStepper sender
     *
     * @return void.
     */
    func rightMileageSave(sender:UIStepper) {
        self.saveMileage()
    }

}