//
//  Mileage.swift
//  Runalysis
//
//  Created by Kevin Hankens on 7/15/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import CoreData

@objc(Mileage)
class Mileage: NSManagedObject {

    // The date of the mileage, tracked as a numeric value.
    @NSManaged var date: NSNumber
    
    // The planned mileage for the specified day.
    @NSManaged var mileagePlanned: NSNumber
    
    // The actual mileage for the specified day.
    @NSManaged var mileageActual: NSNumber
    
    // A note about the day.
    @NSManaged var note: String

}
