//
//  NoteView.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/12/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class NoteView : UIView, UITextViewDelegate {
    
    // The date representation that we are working with.
    var dayNum: JLDate?
    
    // The core data storage for mileage.
    var store: MileageStore?
    
    // The core data storage for routes.
    var routeStore: RouteStore?
    
    // The ID of the currently viewed route.
    var routeId: NSNumber = 0
    
    // Tracks the label on the page.
    var label: UILabel?
    
    var labelHi: UILabel?
    
    // The note that should be saved to the db.
    var note: UITextView?
    
    var reviewButton: UIButton?
    
    var controller: UIViewController?
    
    /*!
     * Factory method to create a NoteView object.
     *
     * @param CGFloat x
     * @param CGFloat y
     * @param CGFloat width
     * @param CGFloat height
     * @param JLDate dayNum
     * @param MileageStore mileageStore
     * @param RouteStore routeStore
     * @param UIViewController controller
     *
     * @return NoteView
     */
    class func createNoteView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, dayNum: JLDate, mileageStore: MileageStore, routeStore: RouteStore, controller: UIViewController)->NoteView {
    
        let container = NoteView(frame: CGRectMake(x, y, width, height))
        container.dayNum = dayNum
        container.routeStore = routeStore
        container.store = mileageStore
        container.controller = controller
        
        var ypos = CGFloat(10.0)
        
        let noteLabel = UILabel(frame: CGRect(x: 10, y: ypos, width: container.bounds.width - 10, height: GlobalTheme.getNormalFontHeight()))
        noteLabel.textColor = GlobalTheme.getNormalTextColor()
        noteLabel.font = GlobalTheme.getNormalFont()
        noteLabel.text = ""
        container.label = noteLabel
        container.addSubview(noteLabel)
        
        let noteLabelHi = UILabel(frame: CGRect(x: 10, y: ypos, width: container.bounds.width - 10, height: GlobalTheme.getNormalFontHeight()))
        noteLabelHi.textColor = GlobalTheme.getNormalTextAlertColor()
        noteLabelHi.font = GlobalTheme.getNormalFont()
        noteLabelHi.alpha = 0.0
        noteLabelHi.text = ""
        container.labelHi = noteLabelHi
        container.addSubview(noteLabelHi)
        
        
        let reviewButton = UIButton()
        reviewButton.frame = CGRectMake(container.bounds.width/2, ypos, container.bounds.width/2 - 10, GlobalTheme.getNormalFontHeight())
        reviewButton.setTitle("Review", forState: UIControlState.Normal)
        reviewButton.titleLabel?.font = GlobalTheme.getNormalFont()
        reviewButton.setTitleColor(GlobalTheme.getBackgroundColor(), forState: UIControlState.Normal)
        reviewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right
        reviewButton.backgroundColor = GlobalTheme.getBackgroundColor()
        reviewButton.addTarget(container, action: "viewRoute:", forControlEvents: UIControlEvents.TouchDown)
        container.reviewButton = reviewButton
        container.addSubview(reviewButton)
        
        ypos += noteLabel.frame.height + 10
        
        // @todo the note view should really be its own controller w/segue.
        let noteView = UITextView(frame: CGRect(x: 10, y: ypos, width: container.bounds.width - 5, height: 200.00))
        noteView.editable = true
        noteView.text = ""
        noteView.delegate = container
        container.note = noteView
        //noteView.becomeFirstResponder()
        container.addSubview(noteView)
        
        let keyboardDismissTap = UITapGestureRecognizer(target: container, action: "dismissKeyboard:")
        container.addGestureRecognizer(keyboardDismissTap)
        
        container.updateDay(dayNum)
        
        return container
    }

    
    func dismissKeyboard(gesture: UITapGestureRecognizer) {
        if let n = self.note? {
            n.resignFirstResponder()
        }
    }
    
    func viewRoute(sender: UIButton) {
        if let c = self.controller as? NoteViewController {
            if let d = self.dayNum? {
                let routeId = self.routeStore!.getFirstRoutIdForDate(date: self.dayNum!.date.timeIntervalSince1970)
                if let day = routeId? {
                    c.viewRoute(routeId!)
                }
                else {
                    let alert = UIAlertView(title: "Unavailable", message: "No workouts found for this day.", delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
    }
  
    /*!
     * Updates the currently viewed day.
     *
     * @param JLDate day
     */
    func updateDay(day: JLDate) {
        self.dayNum = day
        
        // Storage engine.
        let mileageData = self.store!.getMileageForDate(self.dayNum!)
        
        if let l = self.label? {
            if let lh = self.labelHi? {
                let text = day.toStringMedium()
                l.text = text
                lh.text = text
                lh.alpha = 1.0
                UIView.animateWithDuration(0.75, animations: {lh.alpha = 0.0})
            }
        }
        
        // See if there is a route for this day.
        if let r = self.reviewButton? {
            let routeId = self.routeStore!.getFirstRoutIdForDate(date: self.dayNum!.date.timeIntervalSince1970)
            
            if let day = routeId? {
                r.enabled = true
                r.setTitleColor(GlobalTheme.getRecentTextColor(), forState: UIControlState.Normal)
            }
            else {
                r.setTitleColor(GlobalTheme.getBackgroundColor(), forState: UIControlState.Normal)
                r.enabled = false
            }
        }
        
        if let n = self.note? {
            n.text = mileageData.note
        }
    }
    
    /*!
     * Saves the currently entered note
     */
    func saveNote() {
        if let n = self.note? {
            let day = self.dayNum!.nextDay(increment: 0)
            let text = n.text.stringByAppendingString("")
            // @todo, this breaks saving for some reason.
            // Save the note to the db asynchronously.
            //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                //println("saving d: \(day.number) text: \(text)")
                self.store!.setNoteForDay(day, note: text)
                self.store!.saveContext()
                //})
        }
    }

}
