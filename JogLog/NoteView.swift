//
//  NoteView.swift
//  JogLog
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
    
    // The note that should be saved to the db.
    var note: UITextView?
    
    /*!
     * Factory method to create a NoteView object.
     *
     * @param CGFloat x
     * @param CGFloat y
     * @param CGFloat width
     * @param CGFloat height
     * @param JLDate dayNum
     *
     * @return NoteView
     */
    class func createNoteView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, dayNum: JLDate, mileageStore: MileageStore, routeStore: RouteStore)->NoteView {
    
        let container = NoteView(frame: CGRectMake(x, y, width, height))
        container.dayNum = dayNum
        container.routeStore = routeStore
        container.store = mileageStore
        
        var ypos = CGFloat(10.0)
        
        // @todo add a swipe gesture to move the daynum and possibly the week.
        let noteLabel = UILabel(frame: CGRect(x: 10, y: ypos, width: container.bounds.width - 10, height: 20.00))
        noteLabel.textColor = GlobalTheme.getNormalTextColor()
        noteLabel.text = ""
        container.label = noteLabel
        
        let daySwipeLeft = UISwipeGestureRecognizer(target: container, action: "daySwipeGesture:")
        daySwipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        container.addGestureRecognizer(daySwipeLeft)
        
        let daySwipeRight = UISwipeGestureRecognizer(target: container, action: "daySwipeGesture:")
        daySwipeRight.direction = UISwipeGestureRecognizerDirection.Right
        container.addGestureRecognizer(daySwipeRight)
        
        container.addSubview(noteLabel)
        
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
    
    /*!
     * Handle a swipe gesture on the view.
     * 
     * @param UIGestureRecognizer gesture
     *
     * @return void
     */
    func daySwipeGesture(gesture: UIGestureRecognizer) {
        if let g = gesture as? UISwipeGestureRecognizer {
            // Update the day of the note.
            var day = self.dayNum!
            switch g.direction {
            case UISwipeGestureRecognizerDirection.Left:
                day = self.dayNum!.nextDay(increment: 1)
                break;
            case UISwipeGestureRecognizerDirection.Right:
                day = self.dayNum!.prevDay(increment: 1)
                break;
            default:
                break;
            }
            self.saveNote()
            self.updateDay(day)
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
            l.text = day.toStringMedium()
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