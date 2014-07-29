//
//  NoteViewController.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/25/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class NoteViewController: UIViewController {
   
    // The date representation that we are working with.
    var dayNum: NSNumber = 0
    
    // The core data storage.
    var store: MileageStore = MileageStore()
    
    var note: UITextView?
    
    var triggeringCell: RockerCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        let backButton = UIButton(frame: CGRect(x: 10, y: 30, width: self.view.bounds.width/2, height: 20.00))
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
        
        let mileageData = self.store.getMileageForDate(self.dayNum)
        let mileage = MileageId.createFromNumber(mileageData.date)
        
        var cell = RockerCell.createCell(mileage.toStringShort(), cellHeight: 50.0, cellWidth: self.view.bounds.width, cellY: 50.0, day: self.dayNum, summary: nil, controller: self)
        self.view.addSubview(cell)
       
        //println("\(self.dayNum)")
        //println("\(mileageData.mileagePlanned)")
        //println("\(mileageData.mileageActual)")
        //println("\(mileageData.note)")
        
        let noteLabel = UILabel(frame: CGRect(x: 10, y: 110, width: self.view.bounds.width, height: 20.00))
        noteLabel.text = "Notes:"
        noteLabel.textColor = GlobalTheme.getNormalTextColor()
        self.view.addSubview(noteLabel)
        
        let noteView = UITextView(frame: CGRect(x: 10, y: 140, width: self.view.bounds.width, height: 200.00))
        noteView.editable = true
        noteView.text = mileageData.note
        self.note = noteView
        self.view.addSubview(noteView)
        
    }
    
    /*!
     * Button responder.
     *
     * Saves the current note and removes this modal.
     *
     * @param UIButton sender
     */
    func returnToRootView(sender: UIButton) {
        println("pressed")
        if let cell = self.triggeringCell as? RockerCell {
            cell.updateDate(cell.dayNum)
        }
        let note = self.note!
        self.store.setNoteForDay(self.dayNum, note: note.text)
        self.store.saveContext()
        println("dismissing")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}