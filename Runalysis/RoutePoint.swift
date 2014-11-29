//
//  RoutePoint.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/21/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation

class RoutePoint: NSObject {

    var routeid: NSNumber = 0
    var date: NSNumber = 0
    var latitude: NSNumber = 0.0
    var longitude: NSNumber = 0.0
    var altitude: NSNumber = 0.0
    var velocity: NSNumber = 0.0
    var velocityMovingAvg: NSNumber = 0.0
    var distance: NSNumber = 0.0
    var relativeVelocity: NSNumber = 0

}
