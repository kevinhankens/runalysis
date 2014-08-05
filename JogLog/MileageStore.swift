//
//  MileageStore.swift
//  JogLog
//
//  Created by Kevin Hankens on 7/16/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/*!
 * @class MileageStore
 *
 * Handles Core Data integration with the AppDelgate.
 *
 * @example
 * @todo update to new spec
 *  let ms = MileageStore()
 *  let date = JLDate.createFromDate(NSDate())
 *  let test1 = ms.getMileageForDate(date)
 *  println("created: \(test1)")
 *  ms.setMileageForDay(date, planned: 1.25, actual: 2.5, note:"My note.")
 *  let next = date.nextDay()
 *  let test2 = ms.getMileageForDate(next)
 *  ms.setNoteForDay(next, note:"My note.")
 *  println("retrieved: \(test2)")
 *  ms.saveContext()
 */
class MileageStore {
    
    /*!
     * @var NSManagedObjectContext
     *   Returns the shared Manged Object Context.
     */
    var context: NSManagedObjectContext {
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        return app.managedObjectContext
    }

    /*!
     * Saves the shared context.
     *
     * @return void
     */
    func saveContext() {
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        app.saveContext()
    }
    
    /*!
     * Gets the mileage for a particular day.
     *
     * @param JLDate day
     *   The date of the object to retrieve.
     *
     * @return Mileage
     */
    func getMileageForDate(day: JLDate)->Mileage {
        // @todo error handling?
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Mileage")
        
        fReq.predicate = NSPredicate(format:"date == \(day.number)")
        //fReq.predicate = NSPredicate(format:"id == 1")
        
        //var sorter: NSSortDescriptor = NSSortDescriptor(key: "date" , ascending: false)
        //fReq.sortDescriptors = [sorter]
        
        var result = self.context.executeFetchRequest(fReq, error:&error)

        for resultItem : AnyObject in result {
            var mileageItem = resultItem as Mileage
            return mileageItem
        }
        
        // If we didn't find one, create a new one.
        var mileageItem = self.getMileageObject(day)
        
        return mileageItem
    }
    
    /*!
     * Prepares a new mileage object in the shared context.
     *
     * @param JLDate day
     *   The date of the object to retrieve.
     *
     * @return Mileage
     */
    func getMileageObject(day: JLDate)->Mileage {
        var obj = NSEntityDescription.insertNewObjectForEntityForName("Mileage", inManagedObjectContext: self.context) as Mileage
        obj.date = day.number
        obj.mileagePlanned = 0
        obj.mileageActual = 0
        obj.note = ""
        
        return obj
    }
    
    /*!
     * Sets the mileage for a particular day.
     *
     * @param JLDate day
     *   The date of the object to retrieve.
     * @param NSNumber planned
     *   The number of miles planned.
     * @param NSNumber actual
     *   The number of actual miles accomplished.
     * @param NSString note
     *   A note about the day.
     *
     * @return void
     */
    func setMileageForDay(day: JLDate, planned: NSNumber, actual: NSNumber, note: NSString) {
        let obj = self.getMileageForDate(day)
        obj.mileagePlanned = planned
        obj.mileageActual = actual
        if note != "" {
          obj.note = note
        }
        
    }
    
    /*!
     * Sets a note for the specified day.
     *
     * @param JLDate day
     *   The date of the object to retrieve.
     * @param NSString note
     *   A note about the day.
     *
     * @return void
     */
    func setNoteForDay(day: JLDate, note: NSString) {
        let obj = self.getMileageForDate(day)
          obj.note = note
    }

}