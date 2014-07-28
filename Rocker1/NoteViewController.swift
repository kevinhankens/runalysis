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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        let backButton = UIButton(frame: CGRect(x: 10, y: 20, width: 50.00, height: 20.00))
        backButton.setTitle("Back", forState: UIControlState.Normal)
        backButton.setTitleColor(GlobalTheme.getNormalTextColor(), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(backButton)
       
        let mileageData = self.store.getMileageForDate(self.dayNum)
        //println("\(self.dayNum)")
        //println("\(mileageData.mileagePlanned)")
        //println("\(mileageData.mileageActual)")
        //println("\(mileageData.note)")
        
        let mileage = MileageId.createFromNumber(mileageData.date)
        let dateLabel = UILabel(frame: CGRect(x: 10, y: 50, width: self.view.bounds.width, height: 20.00))
        dateLabel.text = "Date: \(mileage.toStringShort())"
        dateLabel.textColor = GlobalTheme.getNormalTextColor()
        self.view.addSubview(dateLabel)
        
        let plannedLabel = UILabel(frame: CGRect(x: 10, y: 80, width: self.view.bounds.width, height: 20.00))
        plannedLabel.text = "Planned: \(mileageData.mileagePlanned)"
        plannedLabel.textColor = GlobalTheme.getNormalTextColor()
        self.view.addSubview(plannedLabel)
       
        let actualLabel = UILabel(frame: CGRect(x: 10, y: 110, width: self.view.bounds.width, height: 20.00))
        actualLabel.text = "Actual: \(mileageData.mileageActual)"
        actualLabel.textColor = GlobalTheme.getNormalTextColor()
        self.view.addSubview(actualLabel)
        
        let noteLabel = UILabel(frame: CGRect(x: 10, y: 140, width: self.view.bounds.width, height: 20.00))
        noteLabel.text = "Notes:"
        noteLabel.textColor = GlobalTheme.getNormalTextColor()
        self.view.addSubview(noteLabel)
        
        let noteView = UITextView(frame: CGRect(x: 10, y: 170, width: self.view.bounds.width, height: 200.00))
        noteView.editable = true
        noteView.text = mileageData.note
        self.note = noteView
        self.view.addSubview(noteView)
        
    }
    
    func returnToRootView(sender: UIButton) {
        let note = self.note!
        self.store.setNoteForDay(self.dayNum, note: note.text)
        self.store.saveContext()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}