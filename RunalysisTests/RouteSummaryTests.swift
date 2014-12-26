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
    
    //var number = 20141008
    var dateId = 1413234992
    
    let dateIds: [NSNumber] = [1413234992, 1413117331]
    
    let expectedPaces: [String] = ["7:41", "4:46", "6:31", "4:03"]
    
    let expectedDistances: [String] = ["0.19", "0.30", "0.21", "0.34"]
    
    var t1 = Double(0.0)
    var t2 = Double(0.0)
    
    let expectedDistributions: [[Int]] = [
        // date 1 velocity.
        [2, 0, 0, 2, 5, 5, 4, 1, 1],
        // date 1 moving avg.
        [2, 0, 0, 2, 5, 5, 4, 1, 1],
        // date 2 velocity.
        [2, 1, 0, 6, 4, 4, 0, 1, 2],
        // date 2 moving avg.
        [2, 1, 0, 6, 4, 4, 0, 1, 2],
    ]
    
    var routeStore = RouteStoreMock()
    
    let TestRoutePoints2: [[NSNumber]] = [
        // Route 1.
        [1413234992,1413236893.42056,14.2670208656467,4.19115298986435, 42.4972923752316,-71.1928996537544,3.40408018990221,3.40408018990221,0,66.2237205505371],
        [1413234992,1413236898.42108,16.6353577320326,5.00051498413086, 42.4972585961618,-71.192703014306,3.32672890388789,3.32672890388789,0,67.3999900817871],
        [1413234992,1413236903.37107,17.2346958190515,4.94999098777771, 42.4971788842627,-71.1925231386639,3.48176307019681,3.48176307019681,0,67.3254051208496],
        [1413234992,1413236907.41714,15.4585052095436,4.04607003927231, 42.4970940174931,-71.1923741084255,3.82062224813188,3.82062224813188,0,67.4607810974121],
        // Contains an outlier in velocity.
        [1413234992,1413236912.38683,22.7490251179979,4.96969395875931, 42.4969621282467,-71.1921626330085,4.57755051051015,4.334341187471634,0,66.6310081481934],
        [1413234992,1413236916.41041,14.7848862123596,4.02358400821686, 42.4968803627812,-71.1920207273878,3.67455636123574,3.67455636123574,0,66.8000755310059],
        [1413234992,1413236920.41961,13.7855056153955,4.00919699668884, 42.4968063505762,-71.1918861140229,3.43847050339027,3.43847050339027,0,66.7321434020996],
        [1413234992,1413236925.24664,16.1193450621609,4.82703298330307, 42.4967540055909,-71.1917032208957,3.33938987322407,3.33938987322407,0,66.6757469177246],
        [1413234992,1413236929.40123,14.734196127387,4.15458703041077, 42.4967014091485,-71.1915386841364,3.54648874112772,3.54648874112772,0,66.8590965270996],
        [1413234992,1413236934.41712,19.446698136141,5.01588398218155, 42.4966562725999,-71.1913101096369,3.77702311401611,3.77702311401611,0,66.7669944763184],
        [1413234992,1413236939.36428,20.2512020576257,4.94716203212738, 42.4965703161829,-71.1910928507067,4.09349884360211,4.09349884360211,0,66.8039207458496],
        [1413234992,1413236944.3625,16.9657306816293,4.99822098016739, 42.4964862456941,-71.1909206025965,3.39435386089334,3.39435386089334,0,67.1861839294434],
        [1413234992,1413236948.40581,11.88762149295,4.0433149933815, 42.4964063661569,-71.1908246298052,2.94006811549654,2.94006811549654,0,66.6010398864746],
        [1413234992,1413236952.4383,12.7926769377667,4.03249001502991, 42.4963077949756,-71.1907444149919,3.1724013922132,3.1724013922132,0,66.0721702575684],
        [1413234992,1413236956.43937,17.1345956075121,4.00106698274612, 42.4961685296544,-71.1906564888276,4.28250656172514,4.28250656172514,0,64.6473045349121],
        [1413234992,1413236961.24559,16.0141680162686,4.80621701478958, 42.4960293481522,-71.1906061135895,3.33196939859149,3.33196939859149,0,64.1289329528809],
        [1413234992,1413236965.43241,9.22093039655016,4.18681997060776, 42.4959490914294,-71.1905776151188,2.20237088321991,2.20237088321991,0,63.8918724060059],
        [1413234992,1413236970.22344,16.0392000892512,4.79103004932404, 42.4958055513375,-71.1905568279989,3.34775610341124,3.34775610341124,0,63.5877342224121],
        [1413234992,1413236975.23794,15.6233750569896,5.01450198888779, 42.4956655735546,-71.19053855545,3.11563842064699,3.11563842064699,0,63.3577537536621],
        [1413234992,1413236979.23516,15.0749502069608,4.05549299716949, 42.4955315050133,-71.1905144155688,3.71716834857864,3.71716834857864,0,62.1253929138184],
        
        // Route 2
        [1413117331,1413120002.28335,19.6760801441215,4.8247030377388, 43.7884209165757,-70.2591097914337,4.0781950702904,4.0781950702904,0,28.0890254974365],
        [1413117331,1413120006.34223,20.2006756399843,4.05887895822525, 43.7882391130959,-70.2591118030904,4.9769100896808,4.9769100896808,0,28.1463985443115],
        [1413117331,1413120010.43674,15.8884021153565,4.09450900554657, 43.7880967045611,-70.2591295727252,3.88041694225939,3.88041694225939,0,27.9617977142334],
        [1413117331,1413120015.25774,18.2886538760418,4.82100200653076, 43.7880056351831,-70.2593177464514,3.79353791001687,3.79353791001687,0,26.315465927124],
        // Outlier in velocity.
        [1413117331,1413120019.43559,22.7946486283347,4.17785203456879, 43.7880194234138,-70.2595993783979,5.45606891764596,5.095820204464192,0,24.4596309661865],
        [1413117331,1413120024.39148,22.9852754112734,4.9558909535408, 43.7880363129487,-70.2598838601916,4.63797037238103,4.63797037238103,0,23.7209529876709],
        [1413117331,1413120028.42917,17.4976977740335,4.03768301010132, 43.7880471256038,-70.2601004485695,4.33359868277386,4.33359868277386,0,22.8019771575928],
        [1413117331,1413120033.26884,19.3087679492844,4.83966702222824, 43.7880394142529,-70.2603399195431,3.98968934445295,3.98968934445295,0,23.5834102630615],
        [1413117331,1413120037.40435,15.9680152272411,4.13550996780396, 43.7880167412048,-70.2605358046202,3.86119616481554,3.86119616481554,0,23.8443050384521],
        [1413117331,1413120042.24858,19.5317154830292,4.84423702955246, 43.7879931042379,-70.2607758623271,4.03194875970668,4.03194875970668,0,22.7110652923584],
        [1413117331,1413120046.29066,15.2844096562247,4.04207801818848, 43.7879959959945,-70.2609655447959,3.7813247511424,3.7813247511424,0,22.0485897064209],
        [1413117331,1413120051.24689,19.9402913214018,4.95622998476028, 43.7879928527808,-70.2612130623965,4.02327805261568,4.02327805261568,0,21.257848739624],
        [1413117331,1413120055.26777,17.1652589829786,4.02087700366974, 43.7879994325748,-70.2614261303751,4.2690335882725,4.2690335882725,0,21.4265193939209],
        [1413117331,1413120060.25496,21.8155215892968,4.98719197511673, 43.7880029110646,-70.2616971173047,4.37430957102592,4.37430957102592,0,21.691930770874],
        [1413117331,1413120064.43127,16.0980648585559,4.176313996315, 43.7880005641317,-70.2618956007718,3.85461075789804,3.85461075789804,0,23.6613216400146],
        [1413117331,1413120069.27884,18.4489869561998,4.84756803512573, 43.788001486141,-70.2621247620045,3.80582321331387,3.80582321331387,0,23.2506771087646],
        [1413117331,1413120073.41015,13.4357695152673,4.13131099939346, 43.7879514461791,-70.262276725909,3.25218060737617,3.25218060737617,0,23.1346187591553],
        [1413117331,1413120077.43672,12.1366006509623,4.02656996250153, 43.7878462532943,-70.2622364927738,3.01412884017601,3.01412884017601,0,22.680944442749],
        [1413117331,1413120082.44567,20.7860990678423,4.1497957891836, 43.7877245480602, -70.2620403562396,5.00894504785538,5.00894504785538,0,22.6331233978271],
        [1413117331,1413120086.32384,13.1699368255982,3.10365036193237, 43.7876526732406,-70.2619117778449,4.2433699965477,4.2433699965477,0,24.23850059509280],
    ]
    
    override func setUp() {
        super.setUp()
       
        for point in self.TestRoutePoints2 {
            self.routeStore.storeRoutePoint(point[0], date: point[1], latitude: point[4], longitude: point[5], altitude: point[9], velocity: point[6], distance_traveled: point[2], interval: point[3], steps: point[8])
        }
        // @todo create a fake route here.
    }
    
    func testCreateRouteSummary() {
        let rs = RouteSummary.createRouteSummary(self.dateId, routeStore: self.routeStore)
        
        var routeCount = 0
        var pointCount = 0
        for date in self.dateIds {
            
            rs.updateRoute(date)
        
            XCTAssertEqual(rs.routeId, date, "The route id should match the summary.")
            
            rs.calculateSummary()
            
            // Test the assigned values.
            // @todo we should iterate over two dates to ensure we can update the route.
            for p in rs.points! {
                if let point = p as? Route {
                    XCTAssertEqual(point.routeid, self.TestRoutePoints2[pointCount][0], "The assigned route id should be persisted.")
                    XCTAssertEqual(point.date, self.TestRoutePoints2[pointCount][1], "The assigned date should be persisted.")
                    XCTAssertEqual(point.latitude, self.TestRoutePoints2[pointCount][4], "The assigned latitude should be persisted.")
                    XCTAssertEqual(point.latitude_raw, point.latitude.doubleValue, "The raw latitude should match the latitude double.")
                    XCTAssertEqual(point.longitude, self.TestRoutePoints2[pointCount][5], "The assigned longitude should be persisted.")
                    XCTAssertEqual(point.longitude_raw, point.longitude.doubleValue, "The raw longitude should match the longitude double.")
                    XCTAssertEqual(point.altitude, self.TestRoutePoints2[pointCount][9], "The assigned altitude should be persisted.")
                    XCTAssertEqual(point.altitude_raw, point.altitude.doubleValue, "The raw altitude_raw should match the altitude double.")
                    // Our elimination of outliers changes the data slightly
                    // which is why we use the 7 index instead of 6 for velocity.
                    // @todo we should persist the original value for testing.
                    self.t1 = point.velocity_raw
                    self.t2 = Double(self.TestRoutePoints2[pointCount][7])
                    if (self.t1 != self.t2) {
                    //if (point.velocity != self.TestRoutePoints2[pointCount][7]) {
                        println("--no match--")
                        println(point.velocity.isEqualToNumber(self.TestRoutePoints2[pointCount][7]))
                        println(t1)
                        println(t2)
                    }
                    XCTAssertTrue((point.velocity.doubleValue == self.TestRoutePoints2[pointCount][7].doubleValue), "The assigned velocity should be adjusted and persisted.")
                    XCTAssertEqual(point.velocity_raw, point.velocity.doubleValue, "The raw velocity should match the velocity double.")
                    XCTAssertEqual(point.distance, self.TestRoutePoints2[pointCount][2], "The assigned distance should be persisted.")
                    XCTAssertEqual(point.interval, self.TestRoutePoints2[pointCount][3], "The assigned interval should be persisted.")
                    XCTAssertEqual(point.steps, self.TestRoutePoints2[pointCount][8], "The assigned steps should be persisted.")
                }
                pointCount++
            }
            
            // Test distance and pace in all system units.
            var unitCount = routeCount * 2
            for unit in [RunalysisUnitsMiles, RunalysisUnitsKilometers] {
                RunalysisUnits.setUnitsType(unit)
                XCTAssertEqual(rs.getTotalAndPace(), self.expectedDistances[unitCount] + RunalysisUnits.getUnitLabel() + " @" + self.expectedPaces[unitCount])
                XCTAssertEqual(rs.totalDistance(), self.expectedDistances[unitCount])
                XCTAssertEqual(rs.avgVelocityInMinutesPerUnit(), self.expectedPaces[unitCount])
                unitCount++
            }
            
            // Test distributions
            XCTAssertEqual(rs.distribution, self.expectedDistributions[routeCount * 2], "Distribution of moving averages should be correct.")
            XCTAssertEqual(rs.distribution, self.expectedDistributions[(routeCount * 2) + 1], "Distribution of moving averages should be correct.")
            
            routeCount++
        }
        
        // Test the quantiles.
        let values: [Double] = [3.37396910780846,3.37396910780856,3.6674018783674,3.6664018783674,3.68351347076916,3.69351347076916,3.70405525338366,3.80250300210812,3.81250300210812,3.81250300210812,3.81250300210812,3.98250300210812,]
        let q1 = rs.locateQuantile(0.25, values: values)
        XCTAssertTrue((q1 == 3.6666518783674), "The quantile should be correct.")
        let q2 = rs.locateQuantile(0.5, values: values)
        XCTAssertTrue((q2 == 3.69878436207641), "The quantile should be correct.")
        let q3 = rs.locateQuantile(0.75, values: values)
        XCTAssertTrue((q3 == 3.81250300210812), "The quantile should be correct.")
        let q4 = rs.locateQuantile(0.90, values: values)
        XCTAssertTrue((q4 == 3.81250300210812), "The quantile should be correct.")
        let q5 = rs.locateQuantile(0.95, values: values)
        XCTAssertTrue((Double(q5) == Double(3.8890030021081197)), "The quantile should be correct.")
        
    }
}