//
//  GlobalTheme.swift
//  Rocker1
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
    
}