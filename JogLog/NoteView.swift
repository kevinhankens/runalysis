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
    var dayNum: JLDate = JLDate.createFromDate(NSDate())
    
    // The core data storage.
    var store: MileageStore = MileageStore()
    
    var label: UILabel?
    
    var prevDay: JLDate?
    
    // The note that should be saved to the db.
    var note: UITextView?
    
    // The rocker cell that triggered this view, for redrawing.
    var triggeringCell: RockerCell?
    
    var parent: ViewController?
    
    class func createNoteView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, parent: ViewController, cell: RockerCell, dayNum: JLDate)->NoteView {
    
        let container = NoteView(frame: CGRectMake(x, y, width, height))
        container.parent = parent
        container.triggeringCell = cell
        
        var ypos = CGFloat(10.0)
        
        // Back button to dismiss this view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(10, ypos, container.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.sizeToFit()
        backButton.addTarget(container, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchUpInside)
        container.addSubview(backButton)
        
        ypos += backButton.frame.height + 10
        
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
        
        let noteView = UITextView(frame: CGRect(x: 10, y: ypos, width: container.bounds.width - 5, height: 200.00))
        noteView.editable = true
        noteView.text = ""
        noteView.delegate = container
        container.note = noteView
        noteView.becomeFirstResponder()
        container.addSubview(noteView)
        
        container.updateDay(dayNum)
        
        return container
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer!)->Bool {
        return true
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
            var day = self.dayNum
            switch g.direction {
            case UISwipeGestureRecognizerDirection.Left:
                day = self.dayNum.nextDay(increment: 1)
                break;
            case UISwipeGestureRecognizerDirection.Right:
                day = self.dayNum.prevDay(increment: 1)
                break;
            default:
                break;
            }
            self.saveNote()
            self.updateDay(day)
            
            // Potentially update the summary/rockers.
            // @todo this is too much responsibility.
            if let p = self.parent as? ViewController {
                let s = p.startOfWeek
                let e = p.endOfWeek
                let d = day.toStringFormat(JLDate.getDateFormatDayNumber()).integerValue
                
                switch g.direction {
                case UISwipeGestureRecognizerDirection.Left:
                    if d == s {
                        p.sunday = p.sunday.nextDay(increment: 7)
                        p.updateHeader()
                    }
                    break;
                case UISwipeGestureRecognizerDirection.Right:
                    if d == e {
                        p.sunday = p.sunday.prevDay(increment: 7)
                        p.updateHeader()
                    }
                    break;
                default:
                    break;
                }
           }
        }
    }
    
    /*!
     * Tracks the back button to dismiss this view.
     *
     * @param UIButton sender
     *
     * @return void
     */
    func returnToRootView(sender: UIButton) {
        if let n = self.note as? UITextView {
            let day = self.dayNum
            let text = n.text
            self.saveNote()
            n.resignFirstResponder()
        }
       
        // Stop editing and roll the rocker cells down in the parent view.
        if let p = self.parent as? ViewController {
            p.view.endEditing(true)
            p.rollCellsDown()
        }
        
        self.removeFromSuperview()
    }
    
    func updateDay(day: JLDate) {
        self.dayNum = day
        
        // Storage engine.
        let mileageData = self.store.getMileageForDate(self.dayNum)
        
        if let l = self.label as? UILabel {
            l.text = day.toStringMedium()
        }
        
        if let n = self.note as? UITextView {
            n.text = mileageData.note
        }
    }
    
    func saveNote() {
        if let n = self.note as? UITextView {
            let day = self.dayNum.nextDay(increment: 0)
            let text = n.text.stringByAppendingString("")
            // Save the note to the db asynchronously.
            //dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                //println("saving d: \(day.number) text: \(text)")
                self.store.setNoteForDay(day, note: text)
                self.store.saveContext()
                //})
        }
    }

}