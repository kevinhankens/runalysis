//
//  NoteViewController.swift
//  Runalysis
//
//  Created by Kevin Hankens on 9/20/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class NoteViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // The scroll view container for this controller.
    var scrollContainer: UIScrollView?
    
    // The height of the content to scroll.
    var scrollContentHeight = CGFloat(0)
 
    // The id of this route, which is a timestamp.
    var routeId: NSNumber = 0
    
    // The core data storage for mileage.
    var dayNum: JLDate?
    
    // The core data storage for mileage.
    var store: MileageStore?
    
    // Tracks the RouteStore object.
    var routeStore: RouteStore?
    
    // Tracks the NoteView object.
    var noteView: NoteView?
    
    // Tracks the Mileage entity object.
    var mileage: Mileage?
    
    // Tracks the UIPickerView object.
    var picker: UIPickerView?
    
    // The width of the left picker.
    var pickerWidthLeft = CGFloat(0)
    
    // The width of the right picker.
    var pickerWidthRight = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = UIScrollView(frame: CGRectMake(0, 20, self.view.frame.width, self.view.frame.height - 20))
        
        self.view.backgroundColor = GlobalTheme.getBackgroundColor()
        
        var ypos = CGFloat(20)
        
        // Add a back button to return to the "root" view.
        let backButton = UIButton()
        backButton.frame = CGRectMake(0, ypos, self.view.bounds.width/2, 20.00)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.titleLabel?.font = UIFont.systemFontOfSize(30.0)
        backButton.titleLabel?.textAlignment = NSTextAlignment.Left
        backButton.setTitleColor(GlobalTheme.getBackButtonTextColor(), forState: UIControlState.Normal)
        backButton.backgroundColor = GlobalTheme.getBackgroundColor()
        backButton.addTarget(self, action: "returnToRootView:", forControlEvents: UIControlEvents.TouchDown)
        container.addSubview(backButton)
        
        ypos = ypos + backButton.frame.height + 10

        self.updateMileage()
        
        // Mileage picker
        let pp = UIPickerView(frame: CGRect(x: 0, y: ypos, width: self.view.frame.width, height: 30))
        pp.delegate = self
        pp.tintColor = GlobalTheme.getNormalTextColor()
        self.picker = pp
        self.updatePickerValues()
        container.addSubview(pp)
        
        ypos = ypos + pp.frame.height + 10
        
        if let routeStore = self.routeStore? {
            if let mileageStore = self.store? {
                if let dayNum = self.dayNum? {
                    let n = NoteView.createNoteView(0, y: ypos, width: self.view.bounds.width - 20, height: self.view.bounds.height, dayNum: self.dayNum!, mileageStore: mileageStore, routeStore: self.routeStore!)
                    container.addSubview(n)
                    self.noteView = n
                    ypos = ypos + n.frame.height
                }
            }
        }
        
        // Add some padding to accomodate scrolling for the keyboard.
        ypos = ypos + container.frame.height/2
        
        self.scrollContentHeight = ypos
        self.scrollContainer = container
        self.view.addSubview(container)
        
        let daySwipeLeft = UISwipeGestureRecognizer(target: self, action: "daySwipeGesture:")
        daySwipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        container.addGestureRecognizer(daySwipeLeft)
        
        let daySwipeRight = UISwipeGestureRecognizer(target: self, action: "daySwipeGesture:")
        daySwipeRight.direction = UISwipeGestureRecognizerDirection.Right
        container.addGestureRecognizer(daySwipeRight)
    }
    
    func updateMileage() {
        if let d = self.dayNum? {
            self.mileage = self.store?.getMileageForDate(self.dayNum!)
            self.updatePickerValues()
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
            if let n = self.noteView? {
                if let d = self.dayNum? {
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
                    self.savePickerValues()
                    self.dayNum = day
                    self.updateMileage()
                    n.saveNote()
                    n.updateDay(day)
                }
            }
        }
    }
    
    func updatePickerValues() {
        if let p = self.picker? {
            if let m = self.mileage? {
                let pm = Int(m.mileagePlanned)
                let pdec = Int(round((m.mileagePlanned - Double(pm)) * 100))
                var pd = Int(0)
                if pdec > 0 {
                    pd = Int(Double(pdec)/Double(5))
                }
                let am = Int(m.mileageActual)
                let adec = Int(round((m.mileageActual - Double(am)) * 100))
                var ad = Int(0)
                if adec > 0 {
                    ad = Int(Double(adec)/Double(5))
                }
                p.selectRow(pm, inComponent: 0, animated: true)
                p.selectRow(pd, inComponent: 1, animated: true)
                p.selectRow(am, inComponent: 2, animated: true)
                p.selectRow(ad, inComponent: 3, animated: true)
            }
        }
    }
    
    func savePickerValues() {
        if let p = self.picker? {
            if let s = self.store? {
                if let d = self.dayNum? {
                    let pm = p.selectedRowInComponent(0)
                    let pd = p.selectedRowInComponent(1)
                    let pdec = Double(pd)/Double(20)
                    let planned = Double(pm) + pdec
                    let am = p.selectedRowInComponent(2)
                    let ad = p.selectedRowInComponent(3)
                    let adec = Double(ad)/Double(20)
                    let actual = Double(am) + adec
                    s.setMileageForDay(self.dayNum!, planned: planned, actual: actual, note: "")
                    s.saveContext()
                }
            }
        }
    }
    
    /*!
    * Implements UIViewController::viewWillAppear:animated
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let container = self.scrollContainer? {
            container.contentSize = CGSizeMake(self.view.bounds.width, self.scrollContentHeight)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let n = self.noteView? {
            if let textview = n.note? {
                //textview.becomeFirstResponder()
            }
        }
    }
    
    /*!
     * Handles the button press to return to the root view.
     */
    func returnToRootView(sender: UIButton) {
        if let n = self.noteView? {
            if let textview = n.note? {
                textview.endEditing(true)
                self.savePickerValues()
                n.saveNote()
                textview.resignFirstResponder()
            }
        }
        
        // @todo too much control, should be able to tell the cell to refresh
        if let vc = self.presentingViewController as? ViewController {
            vc.updateDay()
        }
        
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func shouldAutorotate()->Bool {
        return false
    }
    
    override func supportedInterfaceOrientations()->Int {
        return Int(UIInterfaceOrientationMask.Portrait.toRaw())
        //return Int(UIInterfaceOrientation.Portrait.toRaw())
    }
    
    // UIPickerView Delegate Methods
    // @todo move the picker to a custom view.
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0, 2:
            return 100
        case 1, 3:
            return 20
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0, 2:
            self.pickerWidthLeft = (pickerView.frame.width/4)
            return self.pickerWidthLeft
        case 1, 3:
            self.pickerWidthRight = (pickerView.frame.width/4)
            return self.pickerWidthRight
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(20)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return "\(row)"
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        
        let label = UILabel()
        var rect = CGRect(x: 0, y: 0, width: 40, height: 20)
        switch component {
        case 0, 2:
            rect = CGRect(x: 0, y: 0, width: self.pickerWidthLeft, height: 20)
            label.textAlignment = NSTextAlignment.Right
            label.text = "\(row)."
        case 1, 3:
            rect = CGRect(x: 0, y: 0, width: self.pickerWidthRight, height: 20)
            label.textAlignment = NSTextAlignment.Left
            let rowval = Double(row)/Double(20)
            let rowint = Int(round(rowval * 100))
            var rowtext = "\(rowint)"
            if rowint < 10 {
                rowtext = "0\(rowint)"
            }
            label.text = rowtext
        default:
            rect = CGRect(x: 0, y: 0, width: 40, height: 20)
        }
        
        switch component {
        case 0, 1:
            label.textColor = GlobalTheme.getPlannedColor()
        case 2, 3:
            label.textColor = GlobalTheme.getActualColor()
        default:
            label.textColor = GlobalTheme.getNormalTextColor()
        }
        
        return label
    }
    
    //func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    //}
    
    
}
