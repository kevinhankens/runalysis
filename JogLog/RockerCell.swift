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
class RockerCell: UIView, UIGestureRecognizerDelegate {

    // The cover view which contains the labels.
    var cover: UIView?
   
    // If the cover is currently closing.
    var coverIsClosing: Bool = false
   
    // The boundaries of the left pan.
    var coverBoundsLeft = CGFloat(0)
    
    // The boundaries of the right pan.
    var coverBoundsRight = CGFloat(0)
    
    // The "normal" home position of the cover.
    var coverBoundsNormal = CGFloat(0)
    
    // The Limit to the cover movement.
    var coverBoundsOffset = CGFloat(100)
    
    var finalY = CGFloat(-100)
    
    // The left-hand stepper.
    var leftControl: UIView?
    
    // The right-hand stepper.
    var rightControl: UIView?
    
    // The left-hand label.
    var leftLabel: UIView?
    
    // The right-hand label.
    var rightLabel: UIView?
    
    // The date of this cell.
    // @todo poorly named variable.
    var dayNum: JLDate?
    
    // The core data storage.
    var store: MileageStore?
    
    var routeStore: RouteStore?
    
    // Tracks the summary cell to update when mileages change.
    var summary: SummaryCell?
    
    // Tracks the parent controller to trigger note view segue.
    var controller: UIViewController?
    
    /*!
     * Factory method to create an instance of RockerCell
     *
     * @param String centerText
     *   The text on the cover of the cell.
     * @param CGFloat cellHeight
     *   The height of the cell.
     * @param CGFloat cellWidth
     *   The width of the cell.
     * @param CGFloat cellY
     *   The y-position of the cell.
     * @param JLDate day
     *   The date of the cell.
     * @param SummaryCell? summary
     *   The summary cell that this should update.
     * @param UIViewController? controller
     *   The controller hosting this cell.
     * @param MileageStore? store
     *   The data store for this cell.
     *
     * @return RockerCell
     */
    class func createCell(centerText: String, cellHeight: CGFloat, cellWidth:
        CGFloat, cellY: CGFloat, day: JLDate, summary: SummaryCell?, controller: UIViewController?, store: MileageStore, routeStore: RouteStore)->RockerCell {
        // @todo cgrect size should be args
        // @todo make this 100% width
        // @todo make the steppers injectable?
           
        let container = RockerCell(frame: CGRectMake(0, cellY, cellWidth, cellHeight))
        container.dayNum = day
            
        container.store = store
        container.routeStore = routeStore
            
        // A background color view.
        let leftBg = UIView(frame: CGRect(x: 0, y: 0, width: container.bounds.width/2, height: container.bounds.height))
        leftBg.backgroundColor = GlobalTheme.getPlannedColor()
        container.addSubview(leftBg)
            
        // A background color view.
        let rightBg = UIView(frame: CGRect(x: container.bounds.width/2, y: 0, width: container.bounds.width/2, height: container.bounds.height))
        rightBg.backgroundColor = GlobalTheme.getActualColor()
        container.addSubview(rightBg)
            
        container.summary = summary
        container.controller = controller
            
        let mileageData = container.store!.getMileageForDate(day)
        
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
        let cover = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight))
        cover.backgroundColor = GlobalTheme.getBackgroundColor()
        container.cover = cover
        container.coverBoundsNormal = cover.center.x
        
        let leftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50.00, height: container.bounds.height))
        leftLabel.text = RockerStepper.getLabel(Double(mileageData.mileagePlanned))
        leftLabel.textColor = GlobalTheme.getPlannedColor()
        leftLabel.textAlignment = NSTextAlignment.Center
        container.leftLabel = leftLabel
        cover.addSubview(leftLabel)
        container.coverBoundsLeft = cover.center.x - container.coverBoundsOffset
        
        let centerLabel = UILabel(frame: CGRect(x: (cellWidth/2 - 50), y: 3, width: 100.00, height: cellHeight))
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
        pan.delegate = container
        container.addGestureRecognizer(pan)
            
        // Tap gesture recognizer.
        let tap = UITapGestureRecognizer(target: container, action: "respondToTapGesture:")
        tap.numberOfTapsRequired = 2
        cover.addGestureRecognizer(tap)
        
        container.addSubview(cover)
        
        return container
    }
    
    /*!
     * Delegate the gesture recognizer to see if it is a horizontal pan.
     *
     * If we find a vertical movement, pass that along so that the parent
     * UIScrollView can handle it.
     *
     * @param UIGestureRecognizer
     *
     * @return void
     */
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let v = pan.velocityInView(pan.view)
            return fabs(v.x) > fabs(v.y)
        }
        return true
    }
    
    /*!
     * Handle taps on the rocker cover.
     *
     * @param UITapGestureRecognizer tap
     */
    func respondToTapGesture(tap: UITapGestureRecognizer) {
        if let c = self.controller as? ViewController {
            if let a = c.actionView as? UIView {
                // @todo too much control here, needs delegate.
                let n = NoteView.createNoteView(0, y: 0, width: a.bounds.width, height: a.bounds.height, parent: c, cell: self, dayNum: self.dayNum!, mileageStore: self.store!, routeStore: self.routeStore!)
                a.addSubview(n)
                c.closeAllRockersExcept(except: nil)
                c.rollCellsUp()
            }
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
        
        // Convert the velocity of the pan to a duration.
        var duration = Double(0.1)
        var vv = pan.velocityInView(pan.view)
        if let ll = v.leftControl as? RockerStepper {
            let d = vv.x/ll.frame.width
            duration = Double(1)/(1.5 * fabs(Double(d)))
        }
        
        // Move the cover horizontally based on the pan change.
        if (c.center.x >= v.coverBoundsLeft && c.center.x <= v.coverBoundsRight) {
            pos.x += translation.x
            c.center = pos
            pan.setTranslation(CGPointZero, inView: cover)
        }
        
        // Define some boundaries and react to incomplete pans. We'll use
        // their velocity to determine their intentions.
        if (pan.state == UIGestureRecognizerState.Ended) {
            if (c.center.x <= v.coverBoundsLeft) {
                // Don't allow it to go beyond the left boundary.
                c.center.x = v.coverBoundsLeft
            }
            else if (c.center.x >= v.coverBoundsRight) {
                // Don't allow it to go beyond the right boundary.
                c.center.x = v.coverBoundsRight
            }
            else if (c.center.x > v.coverBoundsNormal && vv.x < 0) {
                // Snap to center if they are right of normal moving left.
                UIView.animateWithDuration(duration, animations: {
                    c.center.x = v.coverBoundsNormal
                    })
            }
            else if (c.center.x > v.coverBoundsNormal && vv.x >= 0) {
                // Snap to right if they are right of the half and moving right.
                UIView.animateWithDuration(duration, animations: {
                    c.center.x = v.coverBoundsRight
                    })
            }
            else if (c.center.x < v.coverBoundsNormal && vv.x >= 0) {
                // Snap to center if they are left of normal and moving right.
                UIView.animateWithDuration(duration, animations: {
                    c.center.x = v.coverBoundsNormal
                    })
            }
            else if (c.center.x > v.coverBoundsLeft && vv.x < 0) {
                // Snap to left if they are left of the half and moving left.
                UIView.animateWithDuration(duration, animations: {
                    c.center.x = v.coverBoundsLeft
                    })
            }
        }
        
        // Make sure that other rocker panels are closed.
        if let p = self.controller as? ViewController {
            if (c.center.x >= v.coverBoundsLeft || c.center.x <= v.coverBoundsRight) {
                p.closeAllRockersExcept(except: self, duration: duration)
            }
        }
    }
    
    /*!
     * Close the cover view by returning it to the 'normal' position.
     *
     * @param Double duration.
     *   The duration of the animation to close the cells.
     *
     * @return void
     */
    func closeCover(duration: Double = 0.1) {
        if !self.coverIsClosing {
            if let p = self.controller as? ViewController {
                if let c = self.cover as? UIView {
                    if (c.center.x != self.coverBoundsNormal) {
                        UIView.animateWithDuration(duration, animations: {
                            c.center.x = self.coverBoundsNormal
                            })
                    }
                }
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
    func updateDate(day: JLDate) {
        let mileageData = self.store!.getMileageForDate(day)
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
        self.store!.setMileageForDay(self.dayNum!, planned: l.value, actual: r.value, note: "")
        self.store!.saveContext()
        
        if let summary = self.summary as? SummaryCell {
            summary.updateValues()
            summary.setNeedsDisplay()
        }
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
