//
//  Mileage.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/15/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import CoreData

class Mileage: NSManagedObject {

    @NSManaged var date: NSNumber
    @NSManaged var mileagePlanned: NSNumber
    @NSManaged var mileageActual: NSNumber
    @NSManaged var note: String

}
