//
//  MileageStoreMock.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/4/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MileageStoreMock: MileageStore {
    
    override var context: NSManagedObjectContext {
        if !(self._context != nil) {
            self._context = NSManagedObjectContext()
            let bundle = NSBundle(forClass: Mileage.self)
            let modelURL = bundle.URLForResource("Runalysis", withExtension: "momd")
            let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
            self._context!.persistentStoreCoordinator = psc
        }
            
        return self._context!
    }
    
    var _context: NSManagedObjectContext?
    
}
