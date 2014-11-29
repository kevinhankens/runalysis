//
//  GlobalTheme.swift
//  Runalysis
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
        return UIColor(red: 28/255, green: 28/255, blue: 28/255, alpha: 1.0)
    }
    
    /*!
     * Retrieves the overlay background color.
     *
     * @return UIColor
     */
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
     * Retrieves the text color opposite of "normal".
     *
     * @return UIColor
     */
    class func getInvertedTextColor()->UIColor {
        return UIColor.blackColor()
    }
    
    /*!
     * Retrieves the color of the back button.
     *
     * @return UIColor
     */
    class func getBackButtonTextColor()->UIColor {
        return self.getSpeedThree()
    }
    
    /*!
     * Retrieves the background color of the back button.
     *
     * @return UIColor
     */
    class func getBackButtonBgColor()->UIColor {
        return UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.0)
    }
    
    /*!
     * Retrieves the color of the distance/avg velocity.
     *
     * @return UIColor
     */
    class func getDistanceVelocityTextColor()->UIColor {
        return self.getSpeedFour()
    }
    
    /*!
     * Retrieves the color of the timer.
     *
     * @return UIColor
     */
    class func getTimerTextColor()->UIColor {
        return self.getSpeedThree()
    }
    
    /*!
     * Retrieves the color of the altitude graph.
     *
     * @return UIColor
     */
    class func getAltitudeGraphColor()->UIColor {
        return UIColor(red: 64/255, green: 64/255, blue: 64/255, alpha: 1.0)
    }
    
    /*!
     * Retrieves the color of the velocity graph.
     *
     * @return UIColor
     */
    class func getVelocityGraphColor()->UIColor {
        return self.getSpeedFour()
    }
    
    /*!
     * Retrieves the color of a text that alerts.
     *
     * @return UIColor
     */
    class func getNormalTextAlertColor()->UIColor {
        return self.getSpeedFive()
    }
    
    /*!
     * Retrieves the color of a substandard accuracy reding.
     *
     * @return UIColor
     */
    class func getAccuracyPoorColor()->UIColor {
        return self.getSpeedOne()
    }
    
    /*!
     * Retrieves the color of a fair accuracy reading
     *
     * @return UIColor
     */
    class func getAccuracyFairColor()->UIColor {
        return self.getSpeedThree()
    }
    
    /*!
     * Retrieves the color of a good accuracy reading
     *
     * @return UIColor
     */
    class func getAccuracyGoodColor()->UIColor {
        return self.getSpeedFive()
    }
    
    /*!
     * Retrieves the color for the "start" controls.
     *
     * @return UIColor
     */
    class func getStartTextColor()->UIColor {
        return UIColor.blackColor()
    }
    
    /*!
     * Retrieves the color of the background of the start button.
     *
     * @return UIColor
     */
    class func getStartBgColor()->UIColor {
        return self.getSpeedFive()
    }
    
    /*!
     * Retrieves the color for the "stop" controls.
     *
     * @return UIColor
     */
    class func getStopTextColor()->UIColor {
        return UIColor.blackColor()
    }
    
    /*!
     * Retrieves the color of the "stop" backgrond.
     *
     * @return UIColor
     */
    class func getStopBgColor()->UIColor {
        return self.getSpeedOne()
    }
    
    /*!
     * Retrieves the color for the average speed text.
     *
     * @return UIColor
     */
    class func getAverageSpeedTextColor()->UIColor {
        return self.getSpeedThree()
    }
    
    /*!
     * Retrieves the color for the "run" controls.
     *
     * @return UIColor
     */
    class func getRunTextColor()->UIColor {
        return self.getSpeedFive()
    }
    
    /*!
     * Retrieves the color for the "recent" controls.
     *
     * @return UIColor
     */
    class func getRecentTextColor()->UIColor {
        return self.getSpeedOne()
    }
    
    /*!
     * Retrieves the tint color for the rocker steppers.
     *
     * @return UIColor
     */
    class func getRockerStepperTintColor()->UIColor {
        return UIColor.blackColor()
    }
    
    /*!
     * Retrieves the global "planned" text color.
     *
     * @return UIColor
     */
    class func getPlannedColor()->UIColor {
        return self.getSpeedThree()
        //return UIColor(red: 69/255, green: 118/255, blue: 173/255, alpha: 1.0)
    }
    
    /*!
     * Retrieves the global "actual" text color.
     *
     * @return UIColor
     */
    class func getActualColor()->UIColor {
        return self.getSpeedFive()
        //return UIColor(red: 69/255, green: 173/255, blue: 125/255, alpha: 1.0)
    }
    
    /*!
     * Retrieves the color of the lowest speed.
     *
     * @return UIColor
     */
    class func getSpeedOne(setAlpha: CGFloat = 1.0)->UIColor {
        return UIColor(red: 255/255, green: 66/255, blue: 66/255, alpha: setAlpha)
    }
    
    /*!
     * Retrieves the color of the second speed.
     *
     * @return UIColor
     */
    class func getSpeedTwo(setAlpha: CGFloat = 1.0)->UIColor {
        return UIColor(red: 255/255, green: 135/255, blue: 66/255, alpha: setAlpha)
    }
    
    /*!
     * Retrieves the color of the middle speed.
     *
     * @return UIColor
     */
    class func getSpeedThree(setAlpha: CGFloat = 1.0)->UIColor {
        return UIColor(red: 255/255, green: 255/255, blue: 66/255, alpha: setAlpha)
    }
    
    /*!
     * Retrieves the color of the fourth speed.
     *
     * @return UIColor
     */
    class func getSpeedFour(setAlpha: CGFloat = 1.0)->UIColor {
        return UIColor(red: 135/255, green: 255/255, blue: 66/255, alpha: setAlpha)
    }
    
    /*!
     * Retrieves the color of the highest speed.
     *
     * @return UIColor
     */
    class func getSpeedFive(setAlpha: CGFloat = 1.0)->UIColor {
        return UIColor(red: 66/255, green: 255/255, blue: 66/255, alpha: setAlpha)
    }
    
    /*!
     * Retrieves the normal font.
     *
     * @return UIColor
     */
    class func getNormalFont()->UIFont {
        return UIFont.systemFontOfSize(18)
    }
    
    /*!
     * Retrieves the height of a container using the normal font.
     *
     * @return UIColor
     */
    class func getNormalFontHeight()->CGFloat {
        return CGFloat(25.0)
    }
}
