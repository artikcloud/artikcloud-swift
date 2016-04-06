//
//  MessagesApiTests.swift
//  ArtikCloudClientTests
//
//  Created by Maneesh Sahu-SSI on 4/4/16.
//  Copyright © 2016 Samsung Strategy and Innovation Center. All rights reserved.
//

import ArtikCloud
import XCTest
import PromiseKit
@testable import ArtikCloudClient

class MessagesApiTests: XCTestCase {
    
    let testTimeout = 100.0

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSendMessage() {
        let sdid = "993925c3cd994bf7a51c620884be65e9"
        let token = "1eef3e3251e147d1ac707a57f6779c49"
        
        let expectation = self.expectationWithDescription("testSendMessage")
        
        ArtikCloudAPI.customHeaders["Authorization"] = "Bearer " + token
        
        let message = MessageAction()
        message.sdid = sdid
        message.ts = 0
        message._type = "message"
        message.data = [ "volume": 5 ]
        
        MessagesAPI.sendMessageAction(data: message).then { messageIDEnvelope -> Void in
            XCTAssertNotNil(messageIDEnvelope.data)
            
            let messageId = messageIDEnvelope.data?.mid
            NSLog("\(messageId)")
            
            MessagesAPI.getNormalizedMessages(uid: nil, sdid: nil, mid: messageIDEnvelope.data?.mid, fieldPresence: nil, filter: nil, offset: nil, count: nil, startDate: nil, endDate: nil, order: nil).then { responseEnvelope -> Void in
                    NSLog("Got Normalized Messages Response")
                    XCTAssertTrue((responseEnvelope.size == 1), "Size should be 1")
                
                    let normalizedMessage = responseEnvelope.data?[0]
                    XCTAssertNotNil(normalizedMessage)
                
                    let volume = normalizedMessage!.data!["volume"] as? NSNumber
                    XCTAssertNotNil(volume)
                    XCTAssertEqual(NSNumber(int: 5), volume)
                
                    expectation.fulfill()
                }.always {
                    // Noop
                }.error { error2 -> Void in
                    XCTFail("Could not retrieve Normalized messasge")
                }
            }.always {
                // Noop for now
            }.error { error -> Void in
                XCTFail("Could not send Message")
                
        }
        
        self.waitForExpectationsWithTimeout(testTimeout, handler: nil)    }

}
