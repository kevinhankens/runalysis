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
    
}