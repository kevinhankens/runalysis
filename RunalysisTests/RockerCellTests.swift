//
//  RockerCellTests.swift
//  Runalysis
//
//  Created by Kevin Hankens on 8/4/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class RockerCellTests: RunalysisTests {

    var testCell: RockerCell?
    var testDate: JLDate?

    override func setUp() {
        super.setUp()
        
        self.testDate = JLDate.createFromDate(NSDate())
        
        let store = MileageStoreMock()
        
        self.testCell = RockerCellMock.createCell("test", cellHeight: 20, cellWidth: 400, cellY: 20, day: self.testDate!, summary: nil, controller: nil, store: store)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testLabels() {
        if let rc = self.testCell as? RockerCell {
            if let ls = rc.leftControl as? RockerStepper {
                ls.value = 1.25
                rc.leftMileageIncrease(ls)
                if let ll = rc.leftLabel as? UILabel {
                    assert(ll.text == RockerStepper.getLabel(ls.value))
                }
            }
            else {
                assert(false, "Unable to locate left control for RockerCell")
            }
        }
    }

    //func testPerformanceExample() {
    //    // This is an example of a performance test case.
    //    self.measureBlock() {
    //        // Put the code you want to measure the time of here.
    //    }
    //}

}
