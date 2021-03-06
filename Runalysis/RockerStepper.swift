//
//  RockerStepper.swift
//  Runalysis
//
//  Created by Kevin Hankens on 7/14/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * @class RockerStepper
 *
 * This is a custom implementation of a UIStepper which provides defaults
 * as well as custom formatting for the value.
 */
class RockerStepper: UIStepper {
    
    /*!
     * Constructor.
     *
     * @param CGRect frame
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        minimumValue = 0.0
        maximumValue = 100.0
        stepValue = 0.25
        autorepeat = true
    }

    required init(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
   
    /*!
     * Gets a custom label based upon the internal value.
     *
     * @param Double miles
     *
     * @return String
     */
    class func getLabel(miles:Double)->String {
        var mval = Int(miles)
        var dval = Int(round((miles - Double(mval)) * 100))
        var dtext = "\(dval)"
        if dval < 10 {
            dtext = "0\(dval)"
        }
        //var numerator = Int(4.0 * rval)
        //
        //var fraction = ""
        //switch numerator {
        //case 1.0:
        //    fraction = "¼"
        //case 2.0:
        //    fraction = "½"
        //case 3.0:
        //    fraction = "¾"
        //default:
        //    fraction = ""
        //}
        
        return "\(Int(miles)).\(dtext)"
    }
}
