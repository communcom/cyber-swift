//
//  RequestAPIEncodingTests.swift
//  CyberSwiftTests
//
//  Created by Chung Tran on 8/9/19.
//  Copyright © 2019 golos.io. All rights reserved.
//

import XCTest
@testable import CyberSwift

class RequestAPIEncodingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func getRequestString(id: Int, methodAPIType: MethodAPIType) -> String {
        let requestParamsType = methodAPIType.introduced()
        let requestAPI          =   RequestAPI(id:          id,
                                               method:      String(format: "%@.%@", requestParamsType.methodGroup, requestParamsType.methodName),
                                               jsonrpc:     "2.0",
                                               params:      requestParamsType.parameters)
        // Encode data
        let jsonEncoder     = JSONEncoder()
        let jsonData        = try! jsonEncoder.encode(requestAPI)
        let jsonString      = String(data: jsonData, encoding: .utf8)!
        return jsonString
    }
    

    func testGetProfile() {
        let methodAPIType = MethodAPIType.getProfile(userID: "tst11dadsprp", appProfileType: .cyber)
            
        XCTAssertEqual(getRequestString(id: 13, methodAPIType: methodAPIType), #"{"id":13,"method":"content.getProfile","jsonrpc":"2.0","params":{"app":"cyber","userId":"tst11dadsprp"}}"#)
       
    }
    
    func testGetFeed() {
        let methodAPIType = MethodAPIType.getFeed(typeMode: .byUser, userID: "tst11dadsprp", communityID: "gls", timeFrameMode: .all, sortMode: .timeDesc, paginationSequenceKey: nil, paginationLimit: 10)
        print(getRequestString(id: 14, methodAPIType: methodAPIType))
    }
    
    func testGetPost() {
        let methodAPIType = MethodAPIType.getPost(userID: "tst11dadsprp", permlink: "fasdfsfas")
        print(getRequestString(id: 15, methodAPIType: methodAPIType))
    }
    
    func testGetPostComments() {
        let methodAPIType = MethodAPIType.getPostComments(userNickName: "asdfasf", permlink: "asdfasdf", sortMode: .time, limit: 80, paginationSequenceKey: "fasdfasdf3234234234234")
        print(getRequestString(id: 16, methodAPIType: methodAPIType))
    }
    
    func testGetOnlyNotifyHistory() {
        let methodAPIType = MethodAPIType.getOnlineNotifyHistory(fromId: "fasdfasdf", paginationLimit: 80, markAsViewed: true, freshOnly: true)
        print(getRequestString(id: 17, methodAPIType: methodAPIType))
    }
    
    func testSetNotify() {
        let value = ResponseAPIGetOptionsNotifyShow(upvote: true, downvote: true, transfer: true, reply: true, subscribe: true, unsubscribe: true, mention: true, repost: true, reward: true, curatorReward: true, witnessVote: true, witnessCancelVote: true).toParam()
        
        let methodAPIType = MethodAPIType.setNotice(options: value, type: .notify, appProfileType: .golos)
        print(getRequestString(id: 18, methodAPIType: methodAPIType))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
