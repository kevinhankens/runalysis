//
//  RouteSummaryTests.swift
//  Runalysis
//
//  Created by Kevin Hankens on 10/8/14.
//  Copyright (c) 2014 Kevin Hankens. All rights reserved.
//

import Foundation
import XCTest

class RouteSummaryTests: RunalysisTests {
    
    var number = 20141008
    
    var routeStore = RouteStoreMock()
    
    var routePoints = [[1412360463,1412360751.57811,11.6520927764105,3.17807298898697,37.32674125,122.01973429,3.6664018783674],
        [1412360463,1412360748.57115,14.8171878043273,4.00026100873947,37.32684623,122.01973256,3.70405525338366],
        [1412360463,1412360744.57089,15.2129058352945,4.00076103210449,37.32697971,122.01972916,3.80250300210812],
        [1412360463,1412360740.57013,14.7412440737885,4.00195199251175,37.32711673,122.01972438,3.68351347076916],
        [1412360463,1412360736.56818,13.5027288567721,4.00203096866608,37.3272494,122.01971639,3.37396910780846]]
    
    override func setUp() {
        super.setUp()
        
        for point in self.routePoints {
            self.routeStore.storeRoutePoint(point[0] as NSNumber, date: point[1] as NSNumber, latitude: point[4] as NSNumber, longitude: point[5] as NSNumber, altitude: 0.0, velocity: point[6] as NSNumber, distance_traveled: point[2] as NSNumber, interval: point[3] as NSNumber, steps: 0)
        }
        // @todo create a fake route here.
    }
    
    func testCreateRouteSummary() {
        let rs = RouteSummary.createRouteSummary(self.number, routeStore: self.routeStore)
        
        rs.calculateSummary()
    }
}