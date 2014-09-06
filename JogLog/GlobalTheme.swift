//
//  GlobalTheme.swift
//  JogLog
//
//  Created by Kevin Hankens on 7/28/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

/*!
 * @class
 *
 * Manages some of the global themes.
 */
class GlobalTheme {

    /*!
     * Retrieves the global background color.
     *
     * @return UIColor
     */
    class func getBackgroundColor()->UIColor {
        return UIColor.blackColor()
    }
    
    class func getOverlayBackgroundColor()->UIColor {
        return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
    }
    
    /*!
     * Retrieves the global "normal" text color.
     *
     * @return UIColor
     */
    class func getNormalTextColor()->UIColor {
        return UIColor.whiteColor()
    }
    
    /*!
     * Retrieves the global "planned" text color.
     *
     * @return UIColor
     */
    class func getPlannedColor()->UIColor {
        return UIColor(red: 69/255, green: 118/255, blue: 173/255, alpha: 1.0)
    }
    
    /*!
     * Retrieves the global "actual" text color.
     *
     * @return UIColor
     */
    class func getActualColor()->UIColor {
        return UIColor(red: 69/255, green: 173/255, blue: 125/255, alpha: 1.0)
    }
    
    class func getSpeedOne()->UIColor {
        return UIColor(red: 255/255, green: 66/255, blue: 66/255, alpha: 1.0)
    }
    
    class func getSpeedTwo()->UIColor {
        return UIColor(red: 255/255, green: 135/255, blue: 66/255, alpha: 1.0)
    }
    
    class func getSpeedThree()->UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 66/255, alpha: 1.0)
    }
    
    class func getSpeedFour()->UIColor {
        return UIColor(red: 135/255, green: 255/255, blue: 66/255, alpha: 1.0)
    }
    
    class func getSpeedFive()->UIColor {
        return UIColor(red: 66/255, green: 255/255, blue: 66/255, alpha: 1.0)
    }
    
}