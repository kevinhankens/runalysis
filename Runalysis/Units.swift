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

let RunalysisUnitsKey: String = "RunalysisUnits"

var RunalysisUnitsType: Int = -1

let RunalysisUnitsMiles = 0

let RunalysisUnitsKilometers = 1

class RunalysisUnits {
    
    /*!
     * Gets the currently configured type of units.
     *
     * @return Int
     */
    class func getUnitsType()->Int {
        if RunalysisUnitsType == -1 {
            RunalysisUnitsType = NSUserDefaults.standardUserDefaults().integerForKey(RunalysisUnitsKey)
        }
        return RunalysisUnitsType
    }
    
    /*!
     * Set the unit type.
     *
     * @param type
     */
    class func setUnitsType(type: Int) {
        RunalysisUnitsType = type
        NSUserDefaults.standardUserDefaults().setInteger(type, forKey: RunalysisUnitsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
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
        case RunalysisUnitsMiles:
            multiple = MilesPerMeter
        case RunalysisUnitsKilometers:
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
        case RunalysisUnitsMiles:
            multiple = MilesPerMeter
        case RunalysisUnitsKilometers:
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
        case RunalysisUnitsMiles:
            label = "mi"
        case RunalysisUnitsKilometers:
            label = "km"
        default:
            label = "mi"
        }
        
        return label
        
    }

}