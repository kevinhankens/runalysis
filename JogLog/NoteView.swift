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
    
    // The note that should be saved to the db.
    var note: UITextView?
    
    // The rocker cell that triggered this view, for redrawing.
    var triggeringCell: RockerCell?
    
    var parent: ViewController?
    
    class func createNoteView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, parent: ViewController, cell: RockerCell, dayNum: JLDate)->NoteView {
    
        let container = NoteView(frame: CGRectMake(x, y, width, height))
        container.parent = parent
        container.triggeringCell = cell
        container.dayNum = dayNum
        
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
        
        // Storage engine.
        let mileageData = container.store.getMileageForDate(container.dayNum)
        let mileage = JLDate.createFromNumber(mileageData.date)
        
        ypos += backButton.frame.height + 10
        
        // @todo add a swipe gesture to move the daynum and possibly the week.
        let noteLabel = UILabel(frame: CGRect(x: 10, y: ypos, width: container.bounds.width - 10, height: 20.00))
        noteLabel.text = dayNum.toStringMedium()
        noteLabel.textColor = GlobalTheme.getNormalTextColor()
        container.addSubview(noteLabel)
        
        ypos += noteLabel.frame.height + 10
        
        let noteView = UITextView(frame: CGRect(x: 10, y: ypos, width: container.bounds.width - 5, height: 200.00))
        noteView.editable = true
        noteView.text = mileageData.note
        noteView.delegate = container
        container.note = noteView
        noteView.becomeFirstResponder()
        container.addSubview(noteView)
        
        return container
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
            n.resignFirstResponder()
        }
        
        // Store the note.
        if let cell = self.triggeringCell as? RockerCell {
            // Redraw the triggering cell in the root view.
            //cell.updateDate(cell.dayNum)
            cell.saveMileage()
        }
        
        // Save the note to the db asynchronously.
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let note = self.note!
            self.store.setNoteForDay(self.dayNum, note: note.text)
            self.store.saveContext()
            })
        
        // Stop editing and roll the rocker cells down in the parent view.
        if let p = self.parent as? ViewController {
            p.view.endEditing(true)
            p.rollCellsDown()
        }
        
        self.removeFromSuperview()
    }

}