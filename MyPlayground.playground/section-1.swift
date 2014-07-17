// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


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

let items = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

func findPreviousSunday()->NSNumber {
    let format = NSDateFormatter()
    format.dateFormat = "EEEE"
    let today = format.stringFromDate(0.days.fromNow)
    var day_count = 0
    var day = ""
    while today != items[day_count] {
        day_count += 1
    }
    day = items[day_count]
    
    format.dateFormat = "yyyyMMdd"
    let num = format.stringFromDate(day_count.days.fromNow).toInt()
    return num!
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

let format = NSDateFormatter()
format.dateFormat = "EEEE"
format.stringFromDate(0.days.fromNow)
format.stringFromDate(3.days.fromNow)
3.days.fromNow
findPreviousSunday()
getNextDay(20140717)
