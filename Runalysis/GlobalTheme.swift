//
//  GlobalTheme.swift
//  Runalysis
//
//  Created by Kevin Hankens on 7/28/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import UIKit

let speedColor0 = UIColor(red: 255/255, green: 66/255, blue: 66/255, alpha: 1.0)
let speedColor1 = UIColor(red: 255/255, green: 135/255, blue: 66/255, alpha: 1.0)
let speedColor2 = UIColor(red: 255/255, green: 185/255, blue: 66/255, alpha: 1.0)
let speedColor3 = UIColor(red: 255/255, green: 225/255, blue: 66/255, alpha: 1.0)
let speedColor4 = UIColor(red: 255/255, green: 255/255, blue: 66/255, alpha: 1.0)
let speedColor5 = UIColor(red: 185/255, green: 255/255, blue: 66/255, alpha: 1.0)
let speedColor6 = UIColor(red: 135/255, green: 255/255, blue: 66/255, alpha: 1.0)
let speedColor7 = UIColor(red: 66/255, green: 255/255, blue: 66/255, alpha: 1.0)
let speedColor8 = UIColor(red: 66/255, green: 255/255, blue: 135/255, alpha: 1.0)

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
        return self.getSpeedColor(4, setAlpha: 1.0)
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
        return self.getSpeedColor(7, setAlpha: 1.0)
    }
    
    /*!
     * Retrieves the color of the timer.
     *
     * @return UIColor
     */
    class func getTimerTextColor()->UIColor {
        return self.getSpeedColor(4, setAlpha: 1.0)
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
        return self.getSpeedColor(4, setAlpha: 1.0)
    }
    
    /*!
     * Retrieves the color of a text that alerts.
     *
     * @return UIColor
     */
    class func getNormalTextAlertColor()->UIColor {
        return self.getSpeedColor(7, setAlpha: 1.0)
    }
    
    /*!
     * Retrieves the color of a substandard accuracy reding.
     *
     * @return UIColor
     */
    class func getAccuracyPoorColor()->UIColor {
        return self.getSpeedColor(0, setAlpha: 1.0)
    }
    
    /*!
     * Retrieves the color of a fair accuracy reading
     *
     * @return UIColor
     */
    class func getAccuracyFairColor()->UIColor {
        return self.getSpeedColor(4, setAlpha: 1.0)
    }
    
    /*!
     * Retrieves the color of a good accuracy reading
     *
     * @return UIColor
     */
    class func getAccuracyGoodColor()->UIColor {
        return self.getSpeedColor(7, setAlpha: 1.0)
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
        return self.getSpeedColor(7, setAlpha: 1.0)
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
        return self.getSpeedColor(0, setAlpha: 1.0)
    }
    
    /*!
     * Retrieves the color for the average speed text.
     *
     * @return UIColor
     */
    class func getAverageSpeedTextColor()->UIColor {
        return self.getSpeedColor(4, setAlpha: 1.0)
    }
    
    /*!
     * Retrieves the color for the "run" controls.
     *
     * @return UIColor
     */
    class func getRunTextColor()->UIColor {
        return self.getSpeedColor(7, setAlpha: 1.0)
    }
    
    /*!
     * Retrieves the color for the "recent" controls.
     *
     * @return UIColor
     */
    class func getRecentTextColor()->UIColor {
        return self.getSpeedColor(0, setAlpha: 1.0)
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
        return self.getSpeedColor(4, setAlpha: 1.0)
        //return UIColor(red: 69/255, green: 118/255, blue: 173/255, alpha: 1.0)
    }
    
    /*!
     * Retrieves the global "actual" text color.
     *
     * @return UIColor
     */
    class func getActualColor()->UIColor {
        return self.getSpeedColor(7, setAlpha: 1.0)
        //return UIColor(red: 69/255, green: 173/255, blue: 125/255, alpha: 1.0)
    }
    
    /*!
     * Retrieves a color based on a numeric speed.
     *
     * @param speed
     * @param setAlpha
     *
     * @return UIColor
     */
    class func getSpeedColor(speed: Int, setAlpha: CGFloat = 1.0)->UIColor {
        var c: UIColor
    
        switch speed {
        case 0: // Red
            c = speedColor0
        case 1: // Redorange
            c = speedColor1
        case 2: // Orange
            c = speedColor2
        case 3: // Orangeyellow
            c = speedColor3
        case 4: // Yellow
            c = speedColor4
        case 5: // Yellowgreen
            c = speedColor5
        case 6: // Yellowgreen
            c = speedColor6
        case 7: // Green
            c = speedColor7
        case 8: // Bluegreen
            c = speedColor8
        default:
            c = speedColor0
        }
        
        return c
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
