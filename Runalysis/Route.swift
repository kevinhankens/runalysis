//
//  Route.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/15/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import CoreData

@objc(Route)
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
    var latitude_raw: Double = 0.0
    var longitude_raw: Double = 0.0
    var velocity_raw: Double = 0.0
    var altitude_raw: Double = 0.0
    var relativeVelocity: Int = 0
    var velocityMovingAvg: Double = 0.0
    var relVelMovingAvg: Int = 0
    
}
