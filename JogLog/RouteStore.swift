//
//  RouteStore.swift
//  JogLog
//
//  Created by Kevin Hankens on 8/15/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RouteStore {

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
     * Stores a point in the database.
     *
     * @param NSNumber routeid
     * @param NSNumber date
     * @param NSNumber latitude
     * @param NSNumber longitude
     * @param NSNumber altitude
     * @param NSNumber velocity
     *
     * @return void
     */
    func storeRoutePoint(routeid: NSNumber, date: NSNumber, latitude: NSNumber, longitude: NSNumber, altitude: NSNumber, velocity: NSNumber) {
        
        var route = NSEntityDescription.insertNewObjectForEntityForName("Route", inManagedObjectContext: self.context) as Route
        
        route.routeid = routeid
        route.date = date
        route.latitude = latitude
        route.longitude = longitude
        route.altitude = altitude
        route.velocity = velocity
 
        self.saveContext()
    }
    
    /*!
     * Gets the id of the latest added route.
     *
     * @return NSNumber
     */
    func getLatestRouteId()->NSNumber? {
        var error: NSError? = nil
        var fetch = NSFetchRequest(entityName: "Route")
        fetch.returnsDistinctResults = true
        let sorter = NSSortDescriptor(key: "routeid", ascending: false)
        fetch.sortDescriptors = [sorter]
        fetch.fetchLimit = 1
        var result = self.context.executeFetchRequest(fetch, error: &error)
    
        for resultItem: AnyObject in result {
            if let r = resultItem as? Route {
                return r.routeid
            }
        }
        
        return nil
    }
    
    /*!
     * Gets the id of the first route available for a day.
     *
     * @param NSNumber date
     * 
     * @return void
     */
    func getFirstRoutIdForDate(date: NSNumber = 0)->NSNumber? {
        let endDate: NSNumber = (60 * 60 * 24) + date
        var error: NSError? = nil
        var fetch = NSFetchRequest(entityName: "Route")
        fetch.returnsDistinctResults = true
        fetch.predicate = NSPredicate(format: "routeid > \(date) AND routeid < \(endDate)")
        let sorter = NSSortDescriptor(key: "routeid", ascending: true)
        fetch.sortDescriptors = [sorter]
        fetch.fetchLimit = 1
        var result = self.context.executeFetchRequest(fetch, error: &error)
        for resultItem: AnyObject in result {
            if let r = resultItem as? Route {
                return r.routeid
            }
        }
    
        return nil
    }
    
    /*!
     * Gets the next (or previous) route relatively.
     * 
     * @param NSNumber day
     * @param Bool prev
     *
     * @return NSNumber
     */
    func getNextRouteId(day: NSNumber, prev: Bool = false)->NSNumber? {
        var error: NSError? = nil
        var fetch = NSFetchRequest(entityName: "Route")
        fetch.returnsDistinctResults = true
        let comp = prev ? "<" : ">"
        fetch.predicate = NSPredicate(format: "routeid \(comp) \(day)")
        let sorter = NSSortDescriptor(key: "routeid", ascending: true)
        fetch.sortDescriptors = [sorter]
        fetch.fetchLimit = 1
        var result = self.context.executeFetchRequest(fetch, error: &error)
        for resultItem: AnyObject in result {
            if let r = resultItem as? Route {
                return r.routeid
            }
        }
    
        return nil       
    }
    
    /*!
     * Gets all of the points for a specified ID.
     *
     * @param NSNumber routeId
     *
     * @return [Route]
     */
    func getPointsForId(routeId: NSNumber)->[Route] {
        var list = [Route]()
        var error: NSError? = nil
        
        var last: NSNumber = 0
        if routeId == 0 {
            if var r = self.getLatestRouteId() as? NSNumber {
                last = r
            }
        }
        else {
            last = routeId
        }
        
        var fetch = NSFetchRequest(entityName: "Route")
        
        fetch.predicate = NSPredicate(format: "routeid == \(last)")
        
        var result = self.context.executeFetchRequest(fetch, error: &error)
        
        for resultItem: AnyObject in result {
            list.append(resultItem as Route)
        }
        
        return list
    }

}
