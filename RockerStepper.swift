//
//  RockerStepper.swift
//  Rocker1
//
//  Created by Kevin Hankens on 7/14/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

class RockerStepper: UIStepper {
    
    init(frame: CGRect) {
        super.init(frame: frame)
        minimumValue = 0.0;
        maximumValue = 100.0;
        stepValue = 0.25;
    }
    
    class func mileageWithFraction(miles:Double)->String {
        var ival = floor(miles)
        var rval = miles - ival
        var numerator = Int(4.0 * rval)
        
        var fraction = ""
        switch numerator {
        case 1.0:
            fraction = "1/4"
        case 2.0:
            fraction = "1/2"
        case 3.0:
            fraction = "3/4"
        default:
            fraction = ""
        }
        
        return "\(Int(miles)) \(fraction)"
    }
}
