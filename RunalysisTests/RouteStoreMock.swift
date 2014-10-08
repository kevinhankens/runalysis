//
//  RouteStoreMock.swift
//  Runalysis
//
//  Created by Kevin Hankens on 10/8/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class RouteStoreMock: RouteStore {
    
    override var context: NSManagedObjectContext {
        if !(self._context != nil) {
            self._context = NSManagedObjectContext()
            let bundle = NSBundle(forClass: Route.self)
            let modelURL = bundle.URLForResource("Runalysis", withExtension: "momd")
            let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
            self._context!.persistentStoreCoordinator = psc
            }
            
            return self._context!
    }
    
    var _context: NSManagedObjectContext?
    
    override func saveContext() {
        if let moc = self._context {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
}