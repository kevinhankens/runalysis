//
//  RockerCell.swift
//  Rocker1
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
    
    // The left-hand stepper.
    var leftControl: UIView?
    
    // The right-hand stepper.
    var rightControl: UIView?
    
    // The left-hand label.
    var leftLabel: UIView?
    
    // The right-hand label.
    var rightLabel: UIView?
    
    // The identifier of the day, e.g. 20140715
    // @todo maybe have a rockerId class?
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
    
    /*!
     * Factory method to create an instance of RockerCell
     *
     * @param String centerText
     * @param Float cellHeight
     * @param Float cellWidth
     * @param Float cellY
     * @param NSNumber day
     *
     * @return RockerCell
     */
    class func createCell(centerText: String, cellHeight: Float, cellWidth:
        Float, cellY: Float, day: NSNumber)->RockerCell {
        // @todo cgrect size should be args
        // @todo make this 100% width
        // @todo make the steppers injectable?
            
        let container = RockerCell(frame: CGRect(x: 0, y: cellY, width: cellWidth, height: 50.00))
        container.dayNum = day
        container.backgroundColor = container.getCoverBgColorHi()
            
        let mileageData = container.store.getMileageForDate(day)
        
        // Create a control panel under the main visible cell.
        let leftControl = RockerStepper(frame: CGRect(x: 3, y: 10, width: 30.00, height: 20.00))
        container.leftControl = leftControl
        leftControl.addTarget(container, action: "leftMileageIncrease:", forControlEvents: UIControlEvents.ValueChanged)
        leftControl.addTarget(container, action: "leftMileageSave:", forControlEvents: UIControlEvents.TouchUpInside)
        leftControl.value = Double(mileageData.mileagePlanned)
        container.addSubview(leftControl)
        
        let rightControl = RockerStepper(frame: CGRect(x: cellWidth - 95, y: 10, width: 30.00, height: 20.00))
        container.rightControl = rightControl
        rightControl.addTarget(container, action: "rightMileageIncrease:", forControlEvents: UIControlEvents.ValueChanged)
        rightControl.addTarget(container, action: "rightMileageSave:", forControlEvents: UIControlEvents.TouchUpInside)
        rightControl.value = Double(mileageData.mileageActual)
        container.addSubview(rightControl)
        
        // Create a cover view.
        let cover = UIView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: 50.00))
        cover.backgroundColor = container.getCoverBgColorNormal()
        container.cover = cover
        
        let leftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50.00, height: container.bounds.height))
        leftLabel.text = "\(mileageData.mileagePlanned)"
        leftLabel.textColor = UIColor.whiteColor()
        container.leftLabel = leftLabel
        cover.addSubview(leftLabel)
        
        let centerLabel = UILabel(frame: CGRect(x: (cellWidth/2 - 50), y: 3, width: 100.00, height: 40.00))
        centerLabel.text = centerText
        centerLabel.textColor = UIColor.whiteColor()
        cover.addSubview(centerLabel)
        
        let rightLabel = UILabel(frame: CGRect(x: cellWidth - 50, y: 0, width: 50.00, height: container.bounds.height))
        rightLabel.text = "\(mileageData.mileageActual)"
        rightLabel.textColor = UIColor.whiteColor()
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
        return UIColor(red: 59/255, green: 173/255, blue: 255/255, alpha: 1.0)
    }
    
    /*!
     * Handles the swipe gesture on the rocker cover.
     *
     * @param UIGestureRecognizer gesture
     *
     * @return void
     */
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
                else {
                    break;
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
                else {
                    break;
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
    
    func updateDate(day: NSNumber) {
        let mileageData = self.store.getMileageForDate(day)
        let lc = self.leftControl! as UIStepper
        let ll = self.leftLabel! as UILabel
        let rc = self.rightControl! as UIStepper
        let rl = self.rightLabel! as UILabel
        
        self.dayNum = day
        lc.value = Double(mileageData.mileagePlanned)
        ll.text = "\(mileageData.mileagePlanned)"
        rc.value = Double(mileageData.mileageActual)
        rl.text = "\(mileageData.mileageActual)"
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
     * @param UIStepper sender
     *
     * @return void.
     */
    func saveMileage() {
        let l = self.leftControl! as UIStepper
        let r = self.rightControl! as UIStepper
        self.store.setMileageForDay(self.dayNum, planned: l.value, actual: r.value)
        self.store.saveContext()
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
