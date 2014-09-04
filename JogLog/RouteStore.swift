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

class RouteStore: NSObject {

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
    func storeRoutePoint(routeid: NSNumber, date: NSNumber, latitude: NSNumber, longitude: NSNumber, altitude: NSNumber, velocity: NSNumber, distance_traveled: NSNumber)->Route {
        
        var route = NSEntityDescription.insertNewObjectForEntityForName("Route", inManagedObjectContext: self.context) as Route
        
        route.routeid = routeid
        route.date = date
        route.latitude = latitude
        route.longitude = longitude
        route.altitude = altitude
        route.velocity = velocity
        route.distance = distance_traveled
 
        self.saveContext()
        
        return route
        
        //let rp = RoutePoint()
        //rp.routeid = routeid
        //rp.date = date
        //rp.latitude = latitude
        //rp.longitude = longitude
        //rp.altitude = altitude
        //rp.velocity = velocity
        //rp.distance = distance_traveled
        
        //return rp
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
     * @return NSNumber?
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
     * @return NSNumber?
     */
    func getNextRouteId(day: NSNumber, prev: Bool = false)->NSNumber? {
        var error: NSError? = nil
        var fetch = NSFetchRequest(entityName: "Route")
        fetch.returnsDistinctResults = true
        let comp = prev ? "<" : ">"
        let sort = prev ? false : true
        fetch.predicate = NSPredicate(format: "routeid \(comp) \(day)")
        let sorter = NSSortDescriptor(key: "routeid", ascending: sort)
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
    func getPointsForId(routeId: NSNumber)->[AnyObject] {
        //var list = [RoutePoint]()
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
        
        let sorter = NSSortDescriptor(key: "date", ascending: true)
        fetch.sortDescriptors = [sorter]
        
        fetch.predicate = NSPredicate(format: "routeid == \(last)")
        
        var result = self.context.executeFetchRequest(fetch, error: &error)
        
        return result
        /*
        for resultItem: AnyObject in result {
            if let r = resultItem as? Route {
                let rp = RoutePoint()
                rp.routeid = r.routeid
                rp.date = r.date
                rp.latitude = r.latitude
                rp.longitude = r.longitude
                rp.altitude = r.altitude
                rp.velocity = r.velocity
                rp.distance = r.distance
                list.append(rp)
            }
        }
        
        return list
        */
    }

}
