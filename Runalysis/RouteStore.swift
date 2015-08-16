//
//  RouteStore.swift
//  Runalysis
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
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        return app.managedObjectContext!
    }

    /*!
     * Saves the shared context.
     *
     * @return void
     */
    func saveContext() {
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
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
     * @param NSNumber distance_traveled
     * @param NSNumber interval
     * @param NSNumber steps
     *
     * @return Route
     */
    func storeRoutePoint(routeid: NSNumber, date: NSNumber, latitude: NSNumber, longitude: NSNumber, altitude: NSNumber, velocity: NSNumber, distance_traveled: NSNumber, interval: NSNumber, steps: NSNumber)->Route {
        
        let routeEntity = "Route"
        var route = NSEntityDescription.insertNewObjectForEntityForName(routeEntity, inManagedObjectContext: self.context) as! Route
        
        // Bad things happen if we end up with nan values in the db.
        route.routeid = isnan(routeid.doubleValue) ? 0 : routeid
        route.date = isnan(date.doubleValue) ? 0 : date
        route.latitude = isnan(latitude.doubleValue) ? 0 : latitude
        route.longitude = isnan(longitude.doubleValue) ? 0 : longitude
        route.altitude = isnan(altitude.doubleValue) ? 0 : altitude
        route.velocity = isnan(velocity.doubleValue) ? 0 : velocity
        route.distance = isnan(distance_traveled.doubleValue) ? 0 : distance_traveled
        route.interval = isnan(interval.doubleValue) ? 0 : interval
        route.steps = isnan(steps.doubleValue) ? 0 : steps
 
        self.saveContext()
        
        return route
    }
    
    /*!
     * Deletes a specified route's points.
     *
     * @param NSNumber routeId
     */
    func deleteRoute(routeId: NSNumber) {
        let points = self.getPointsForId(routeId)
        
        if !points.isEmpty {
            for point in points {
                if let p = point as? Route {
                    self.context.deleteObject(p)
                }
            }
        }
    
        self.saveContext()
    }
    
    /*!
     * Gets the id of the latest added route.
     *
     * @return NSNumber
     */
    func getLatestRouteId()->NSNumber? {
        var error: NSError? = nil
        let routeEntity = "Route"
        var fetch = NSFetchRequest(entityName: routeEntity)
        fetch.returnsDistinctResults = true
        let sorter = NSSortDescriptor(key: "routeid", ascending: false)
        fetch.sortDescriptors = [sorter]
        fetch.fetchLimit = 1
        var result = self.context.executeFetchRequest(fetch, error: &error)
    
        if result != nil {
            for resultItem: AnyObject in result! {
                if let r = resultItem as? Route {
                    return r.routeid
                }
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
        let day: NSNumber = 86400
        let endDate: NSNumber = NSNumber(integer: day.integerValue + date.integerValue)
        var error: NSError? = nil
        let routeEntity = "Route"
        var fetch = NSFetchRequest(entityName: routeEntity)
        fetch.returnsDistinctResults = true
        fetch.predicate = NSPredicate(format: "routeid > \(date) AND routeid < \(endDate)")
        let sorter = NSSortDescriptor(key: "routeid", ascending: true)
        fetch.sortDescriptors = [sorter]
        fetch.fetchLimit = 1
        var result = self.context.executeFetchRequest(fetch, error: &error)
        
        if result != nil {
            for resultItem: AnyObject in result! {
                if let r = resultItem as? Route {
                    return r.routeid
                }
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
        let routeEntity = "Route"
        var fetch = NSFetchRequest(entityName: routeEntity)
        fetch.returnsDistinctResults = true
        let comp = prev ? "<" : ">"
        let sort = prev ? false : true
        fetch.predicate = NSPredicate(format: "routeid \(comp) \(day)")
        let sorter = NSSortDescriptor(key: "routeid", ascending: sort)
        fetch.sortDescriptors = [sorter]
        fetch.fetchLimit = 1
        var result = self.context.executeFetchRequest(fetch, error: &error)
        
        if result != nil {
            for resultItem: AnyObject in result! {
                if let r = resultItem as? Route {
                    return r.routeid
                }
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
            if var r = self.getLatestRouteId() {
                last = r
            }
        }
        else {
            last = routeId
        }
        
        let routeEntity = "Route"
        var fetch = NSFetchRequest(entityName: routeEntity)
        
        let sorter = NSSortDescriptor(key: "date", ascending: true)
        fetch.sortDescriptors = [sorter]
        
        fetch.predicate = NSPredicate(format: "routeid == \(last)")
        
        var result = self.context.executeFetchRequest(fetch, error: &error)
        
        // @todo this could return nil, should be an optional.
        return result!
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
