//
//  CyberSwiftTests.swift
//  CyberSwiftTests
//
//  Created by Chung Tran on 8/5/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import XCTest
@testable import CyberSwift

class GenerateKeysTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenerateKeys() {
        let login = "qwertyupo"
        let masterKey = "88fc6b4a77a2454daa23a39d23df869a52a45b920c024c82b50"
        
        let ram = RestAPIManager.instance
        let keys = ram.rx.generateKeys(login: login, masterKey: masterKey)
        
        XCTAssertEqual(keys["owner"]?.publicKey, "GLS8cRo2ojy2XYTKxHhrbu3WxDHv4YAk3Zc8nuaeygEQYoFRTcpD8")
        XCTAssertEqual(keys["owner"]?.privateKey, "5JbWmTCRoTKdPDotGDYtSG7TKYFrFAswGek3dgKMmF6cNYNkSH2")
        
        XCTAssertEqual(keys["active"]?.publicKey, "GLS7dWXDpua9Kkr15zK7DJUMgrMpHCbBAUdEwsS6ZnGYU61hEoQ5o")
        XCTAssertEqual(keys["active"]?.privateKey, "5KE6Eqo1heMWsUgvHEVsbnPdtBt4CrrcM2ykRLNmVgGB2dkZa6X")
        
        XCTAssertEqual(keys["posting"]?.publicKey, "GLS7cmswh3CiXHRKHo2sJgarGmU7Sx6RY6fNjhXwN6HER6mZZm5ap")
        XCTAssertEqual(keys["posting"]?.privateKey, "5JJt94RyUAAcysHk5fb3UrzD3EnYDPKrFpwCxhUfB7Mnv2nBLk6")
        
        XCTAssertEqual(keys["memo"]?.publicKey, "GLS6pGUjrECqEYS6xqFBxAMTmcJwwuKozofvmjBguRYb9ChoVqKbv")
        XCTAssertEqual(keys["memo"]?.privateKey, "5J68Y8KNfhTYS9gHisRGgYh9ZLFQrY6zRmYxbcJ9svvHj5HYbvn")
    }
    
    func testGenerateKeys2() {
        let login = "asdfghjklrh"
        let masterKey = "08b16023da8543d69f09bbfa2a6e3ed4131bfa837bfd4c98a62"
        
        let ram = RestAPIManager.instance
        let keys = ram.rx.generateKeys(login: login, masterKey: masterKey)
        
        XCTAssertEqual(keys["owner"]?.publicKey, "GLS7NdnpF38MHFRG8jC1sAU2P7PL3gobuhkcRzCPqT81hNwvAkMA4")
        XCTAssertEqual(keys["owner"]?.privateKey, "5Jp6LaVXQf94w48LZ5xMGaaWzKuQBaUs2JhyzoSGPSu3G5V2to4")
        
        XCTAssertEqual(keys["active"]?.publicKey, "GLS69C1454MxjiApZp1SDUfjSYuJRfHXG63GdPgtDdhjrto2Hf21B")
        XCTAssertEqual(keys["active"]?.privateKey, "5JuR2yzvMvFGgYUPmqkW4o6eBmGqavSWhdrcKCLn9MSpKWRe8g3")
        
        XCTAssertEqual(keys["posting"]?.publicKey, "GLS7b2fk39yWn88vrWYa7f7mkrbstjXB1Prsimb3kGVpXbaoigoRv")
        XCTAssertEqual(keys["posting"]?.privateKey, "5JqtE74wWqLWJ5ZRyoJ4LwFfD7KPdmv2G5KysG6qnwohFKDt35W")
        
        XCTAssertEqual(keys["memo"]?.publicKey, "GLS8D15cYRvoRe1DaYeBoCkZuyFk35Ytwp9PCLiAgr1kmFY2x42WG")
        XCTAssertEqual(keys["memo"]?.privateKey, "5JaSC8r1ihnaFqzsWxLfefJ21R2i6qybXk3J88HMBVwXpnDrDk1")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
