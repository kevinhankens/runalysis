//
//  JLDateTests.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/5/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import UIKit
import XCTest

class JLDateTests: RunalysisTests {
    
    let date = NSDate()
    let format = NSDateFormatter()
    var number = 0

    override func setUp() {
        super.setUp()
        
        self.format.dateFormat = JLDate.getDateFormat()
        self.number = self.format.stringFromDate(self.date).toInt()!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /*!
     * Test that the JLDate class has the correct properties defined.
     */
    func testProperties() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    /*!
     * Test that we can create JLDate objects.
     */
    func testCreation() {
        
        let fromDate = JLDate.createFromDate(self.date)
        let fromNumber = JLDate.createFromNumber(self.number)
        let originalNumber = fromDate.number
        
        // Ensure that an object created from NSDate matches one created
        // from an integer value of that same day.
        XCTAssertEqual(fromDate.number, fromNumber.number, "Objects created for the same day using createFromDate and createFromNumber should match.")
        
        var ti = Double(60*60*24)
        let nextDate = fromDate.date.dateByAddingTimeInterval(ti)
        let nextDayFromDate = fromDate.nextDay()
        fromDate.updateByDate(nextDate)
        
        // Ensure that we can get the next day and set a date.
        XCTAssertEqual(fromDate.number, nextDayFromDate.number, "Objects created with a relative date or updated to a relative date should match.")
        
        ti = ti * -1
        let prevDate = fromDate.date.dateByAddingTimeInterval(ti)
        let prevDayFromDate = fromDate.prevDay()
        fromDate.updateByDate(prevDate)
        
        // Ensure that we can get the next day and set a date.
        XCTAssertEqual(fromDate.number, prevDayFromDate.number, "Objects created with a relative date or updated to a relative date should match.")
    }
    
    /*!
     * Test that we can convert JSDate objects.
     */
    func testConversion() {
        // Check that we can convert a date into a number.
        let renderedNum = JLDate.dateToNumber(self.date)
        assert(Int(renderedNum) == self.number, "The number formats should match")
    }

}
