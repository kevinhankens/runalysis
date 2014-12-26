//
//  UnitsTests.swift
//  Runalysis
//
//  Created by Kevin Hankens on 12/25/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import XCTest

class UnitsTests: RunalysisTests {
    
    var distance: Double = 0.0
    
    let distancesMeters: [Double] = [
        1609.34708788644, // 1 mile
        4988.97597244798, // 5k
        9977.95194489596, // 10k
        16093.4708788644, // 10 mile
        21082.4468513124, // 1/2 marathon
        42164.8937026248, // marathon
    ]
    let kilometerConversions: [Double] = [
        1.60934708788644, // 1 mile
        4.98897597244798, // 5k
        9.97795194489596, // 10k
        16.0934708788644, // 10 mile
        21.0824468513124, // 1/2 marathon
        42.1648937026248, // marathon
    ]
    let mileConversions: [Double] = [
        0.99999999999999722, // 1 mile
        3.1000000000000014, // 5k
        6.2000000000000028, // 10k
        9.9999999999999716, // 10 mile
        13.099999999999987, // 1/2 marathon
        26.199999999999974, // marathon
    ]

    override func setUp() {
        super.setUp()
    }
    
    func testUnitConversions() {
    
        // Test conversion fom meters to miles.
        RunalysisUnits.setUnitsType(RunalysisUnitsMiles)
        for var i = 0; i < self.distancesMeters.count; i++ {
            self.distance = RunalysisUnits.convertMetersToUnits(self.distancesMeters[i])
            XCTAssertEqual(distance, mileConversions[i])
        }
        
        // Test conversion from meters to kilometers.
        RunalysisUnits.setUnitsType(RunalysisUnitsKilometers)
        for var i = 0; i < self.distancesMeters.count; i++ {
            self.distance = RunalysisUnits.convertMetersToUnits(self.distancesMeters[i])
            XCTAssertEqual(distance, kilometerConversions[i])
        }
    }

}
