//
//  ViewController.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/13/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import UIKit


extension Int {
    var days: NSDateComponents {
    let comps = NSDateComponents()
        comps.day = self * -1;
        return comps
    }
}

extension NSDateComponents {
    var fromNow: NSDate {
    let cal = NSCalendar.currentCalendar()
        let date = cal.dateByAddingComponents(self, toDate: NSDate.date(), options: nil)
        return date
    }
}

class ViewController: UIViewController {
    
    let items = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var sunday: NSNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ypos:Float = 20.0
        let height:Float = 50.0
        var dayNum = self.findPreviousSunday()
        self.sunday = dayNum
        for day in self.items {
            self.view.addSubview(RockerCell.createCell(day, cellHeight: height, cellWidth: self.view.bounds.width, cellY: ypos, day: dayNum))
            ypos = ypos + height
            dayNum = getNextDay(dayNum)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNextDay(day: NSNumber)->NSNumber {
        let format = NSDateFormatter()
        format.dateFormat = "yyyyMMdd"
        let date = format.dateFromString("\(day)")
        //let ti = NSTimeInterval()
        let tomorrow = date.dateByAddingTimeInterval(60*60*24)
        let num = format.stringFromDate(tomorrow).toInt()
        return num!
    }
    
    func findPreviousSunday()->NSNumber {
        let format = NSDateFormatter()
        format.dateFormat = "EEEE"
        let today = format.stringFromDate(0.days.fromNow)
        var day_count = 0
        var day = ""
        while today != self.items[day_count] {
            day_count += 1
        }
        day = self.items[day_count]
        
        format.dateFormat = "yyyyMMdd"
        let num = format.stringFromDate(day_count.days.fromNow).toInt()
        return num!
    }


}

