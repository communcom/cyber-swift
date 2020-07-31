//
//  ResponseAPIContentGetProfileContactTests.swift
//  CyberSwiftTests
//
//  Created by Chung Tran on 7/29/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import XCTest
@testable import CyberSwift

class ResponseAPIContentGetProfileContactTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testMockData() {
        let mockData = ResponseAPIContentGetProfileContacts.mockData()
        XCTAssertNotNil(mockData)
        XCTAssertEqual(mockData?.facebook?.value, "bender")
        XCTAssertEqual(mockData?.facebook?.default, false)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
