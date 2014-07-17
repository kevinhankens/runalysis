//
//  MileageStore.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/16/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MileageStore {
    
//    let ms = MileageStore()
//    let test1 = ms.getMileageForDate(20140716)
//    println("created: \(test1)")
//    ms.setMileageForDay(test1.date, planned: 1.25, actual: 2.5)
//    let test2 = ms.getMileageForDate(test1.date)
//    println("retrieved: \(test2)")
//    ms.saveContext()
    
    var context: NSManagedObjectContext {
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        return app.managedObjectContext
    }
    
    func saveContext() {
        let app = UIApplication.sharedApplication().delegate as AppDelegate
        app.saveContext()
    }

    func getMileageForDate(day: NSNumber)->Mileage {
        var error: NSError? = nil
        var fReq: NSFetchRequest = NSFetchRequest(entityName: "Mileage")
        
        fReq.predicate = NSPredicate(format:"date == \(day)")
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
    
    func getMileageObject(day: NSNumber)->Mileage {
        var obj = NSEntityDescription.insertNewObjectForEntityForName("Mileage", inManagedObjectContext: self.context) as Mileage
        obj.date = day
        obj.mileagePlanned = 0
        obj.mileageActual = 0
        
        return obj
    }
    
    func setMileageForDay(day: NSNumber, planned: NSNumber, actual: NSNumber) {
        var obj = self.getMileageForDate(day)
        obj.mileagePlanned = planned
        obj.mileageActual = actual
        
    }

}