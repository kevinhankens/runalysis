//
//  Units.swift
//  Runalysis
//
//  Created by Kevin Hankens on 12/11/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation

let MilesPerMeter = Double(0.00062137)
    
let KilometersPerMeter = Double(0.001)

class RunalysisUnits {
    
    /*!
     * Gets the currently configured type of units.
     *
     * @return Int
     */
    class func getUnitsType()->Int {
        let unitsKey = "RunalysisUnits"
        return NSUserDefaults.standardUserDefaults().integerForKey(unitsKey)
    }
    
    /*!
     * Converts meters to the configured unit type.
     *
     * @param meters
     *
     * @return Double
     */
    class func convertMetersToUnits(meters: Double)->Double {
        var multiple = Double(0.0)
        
        switch RunalysisUnits.getUnitsType() {
        case 0:
            multiple = MilesPerMeter
        case 1:
            multiple = KilometersPerMeter
        default:
            multiple = MilesPerMeter
        }
        
        return meters * multiple
    }
    
    /*!
     * Gets the velocity based on the configured unit type.
     *
     * @param velocity
     *
     * @return Double
     */
    class func getVelocityPerUnit(velocity: Double)->Double {
        var multiple = Double(0.0)
        
        switch RunalysisUnits.getUnitsType() {
        case 0:
            multiple = MilesPerMeter
        case 1:
            multiple = KilometersPerMeter
        default:
            multiple = MilesPerMeter
        }
        
        let unitsPerSecond = velocity * multiple
        return unitsPerSecond * Double(3600)
    }
    
    /*!
     * Gets a label based on the configured unit type.
     *
     * @return String
     */
    class func getUnitLabel()->String {
        var label = "mi"
        
        switch RunalysisUnits.getUnitsType() {
        case 0:
            label = "mi"
        case 1:
            label = "km"
        default:
            label = "mi"
        }
        
        return label
        
    }

}