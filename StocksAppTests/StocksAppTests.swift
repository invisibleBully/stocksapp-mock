//
//  StocksAppTests.swift
//  StocksAppTests
//
//  Created by Nii Yemoh on 08/04/2022.
//

import XCTest
@testable import StocksApp

class StocksAppTests: XCTestCase {
    
    
    func testSomething(){
        let number = 1
        let string = "1"
        XCTAssertEqual(number, Int(string), "Numbers do not match...")
    }
    
    
    func testCandleStickDataConversion(){
        
        let doubles: [Double] = Array(repeating: 12.2, count: 10)
        var timeStamps: [TimeInterval] = []
        
        
        for x in 0..<12 {
            let interval = Date().addingTimeInterval(3600 * TimeInterval(x)).timeIntervalSince1970
            timeStamps.append(interval)
        }
        
        timeStamps.shuffle()
        let data = MarketDataResponse(
            open: doubles,
            close: doubles,
            high: doubles,
            low: doubles,
            status: "success",
            timestamps: timeStamps
        )
        
        let candleSticks  = data.candleSticks
        
        XCTAssertEqual(candleSticks.count, data.open.count)
        XCTAssertEqual(candleSticks.count, data.close.count)
        XCTAssertEqual(candleSticks.count, data.high.count)
        XCTAssertEqual(candleSticks.count, data.low.count)
        XCTAssertEqual(candleSticks.count, timeStamps.count)
        //verify sort
        
        let dates = candleSticks.map { $0.date }
        for x in 0..<dates.count - 1 {
            let current = dates[x]
            let next = dates[x+1]
            XCTAssertTrue(current >= next, "Current date should be greater than next date")
        }
    }
    
    
}
