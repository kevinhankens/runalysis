//
//  Route.swift
//  JogLog
//
//  Created by Kevin Hankens on 8/15/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import CoreData

class Route: NSManagedObject {

    @NSManaged var routeid: NSNumber
    @NSManaged var date: NSNumber
    @NSManaged var interval: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var altitude: NSNumber
    @NSManaged var velocity: NSNumber
    @NSManaged var distance: NSNumber
    @NSManaged var steps: NSNumber
    var relativeVelocity: NSNumber = 0
    
}
