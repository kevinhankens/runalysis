//
//  NoteViewController.swift
//  JogLog
//
//  Created by Kevin Hankens on 7/25/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class NoteViewController: UIViewController {
   
    // The date representation that we are working with.
    var dayNum: JLDate = JLDate.createFromDate(NSDate())
    
    // The core data storage.
    var store: MileageStore = MileageStore()
    
    // The note that should be saved to the db.
    var note: UITextView?
    
    // The rocker cell that triggered this view, for redrawing.
    var triggeringCell: RockerCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        let backButton = UIButton()
        backButton.frame = CGRectMake(10, 30, self.view.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchDown)
        self.view.addSubview(backButton)
        
        let mileageData = self.store.getMileageForDate(self.dayNum)
        let mileage = JLDate.createFromNumber(mileageData.date)
        
        let cell = RockerCell.createCell(mileage.toStringMedium(), cellHeight: 50.0, cellWidth: self.view.bounds.width, cellY: 55.0, day: self.dayNum, summary: nil, controller: nil, store: nil)
        self.view.addSubview(cell)
       
        let noteLabel = UILabel(frame: CGRect(x: 10, y: 110, width: self.view.bounds.width, height: 20.00))
        noteLabel.text = "Notes:"
        noteLabel.textColor = GlobalTheme.getNormalTextColor()
        self.view.addSubview(noteLabel)
        
        let noteView = UITextView(frame: CGRect(x: 10, y: 140, width: self.view.bounds.width - 5, height: 200.00))
        noteView.editable = true
        noteView.text = mileageData.note
        self.note = noteView
        self.view.addSubview(noteView)
    }
    
    override func shouldAutorotate()->Bool {
        return false
    }
    
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientation.Portrait.toRaw())
    }
    
    /*!
     * Button responder.
     *
     * Saves the current note and removes this modal.
     *
     * @param UIButton sender
     */
    func returnToRootView(sender: UIButton!) {
        if let p = self.parentViewController as? ViewController {
            // @todo this is a little too much control for this view.
            p.rollCellsDown()
        }

        if let cell = self.triggeringCell as? RockerCell {
            // Redraw the triggering cell in the root view.
            cell.updateDate(cell.dayNum)
            cell.saveMileage()
        }
        
        // Save the note to the db asynchronously.
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let note = self.note!
            self.store.setNoteForDay(self.dayNum, note: note.text)
            self.store.saveContext()
        })
        
        // Return to the root view.
        self.dismissViewControllerAnimated(false, completion: nil)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
