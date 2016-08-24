//
//  MessagesApiTests.swift
//  ArtikCloudClientTests
//
//  Created by Maneesh Sahu-SSI on 4/4/16.
//  Copyright © 2016 Samsung Strategy and Innovation Center. All rights reserved.
//

import ArtikCloudSwift
import XCTest
import PromiseKit
@testable import ArtikCloudClient

class MessagesApiTests: ArtikCloudTests {
    
    let testTimeout = 100.0

    override func setUp() {
        super.setUp()
        
        ArtikCloudAPI.customHeaders["Authorization"] = "Bearer " + getProperty(key: "device1.token")

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSendMessage() {
        let sdid = self.getProperty(key: "device1.id")
        
        let expectation = self.expectationWithDescription("testSendMessage")
        
        let message = Message()
        message.sdid = sdid
        message.ts = 0
        message.data = [ "steps": 500 ]
        
        MessagesAPI.sendMessage(data: message).then { messageIDEnvelope -> Void in
            XCTAssertNotNil(messageIDEnvelope.data)
            
            let messageId = messageIDEnvelope.data?.mid
            NSLog("\(messageId)")
            
            MessagesAPI.getNormalizedMessages(uid: nil, sdid: nil, mid: messageIDEnvelope.data?.mid, fieldPresence: nil, filter: nil, offset: nil, count: nil, startDate: nil, endDate: nil, order: nil).then { responseEnvelope -> Void in
                    NSLog("Got Normalized Messages Response")
                    XCTAssertTrue((responseEnvelope.size == 1), "Size should be 1")
                
                    let normalizedMessage = responseEnvelope.data?[0]
                    XCTAssertNotNil(normalizedMessage)
                
                    let steps = normalizedMessage!.data!["steps"] as? NSNumber
                    XCTAssertNotNil(steps)
                    XCTAssertEqual(NSNumber(int: 500), steps)
                
                    expectation.fulfill()
                }.always {
                    // Noop
                }.error { error2 -> Void in
                    XCTFail("Could not retrieve Normalized message. Reason \(error2)")
                }
            }.always {
                // Noop for now
            }.error { error -> Void in
               
                XCTFail("Could not send Message \(error)")
                
        }
        
        self.waitForExpectationsWithTimeout(testTimeout, handler: nil)
    }

    
    func testSendActions() {
        let ddid = self.getProperty(key: "device4.id")
        
        let expectation = self.expectationWithDescription("testSendActions")
        
        let action = Action()
        action.name = "setVolume"
        action.parameters = [ "volume": 5]
        
        let actionArray = ActionArray()
        actionArray.actions = [action]
        
        let actions = Actions()
        actions.ddid = ddid
        actions.ts = 0
        actions.type = "action"
        actions.data = actionArray
        
        ArtikCloudAPI.customHeaders["Authorization"] = "Bearer " + getProperty(key: "device4.token")
        
        MessagesAPI.sendActions(data: actions).then { messageIDEnvelope -> Void in
            XCTAssertNotNil(messageIDEnvelope.data)
            
            let messageId = messageIDEnvelope.data?.mid
            NSLog("\(messageId)")
            
            MessagesAPI.getNormalizedActions(uid: nil, ddid: nil, mid: messageId, offset: nil, count: nil, startDate: nil, endDate: nil, order: nil ).then { responseEnvelope -> Void in
                NSLog("Got Normalized Messages Response \(responseEnvelope)")
                XCTAssertTrue((responseEnvelope.size == 1), "Size should be 1")
                
                let normalizedMessage = responseEnvelope.data?[0]
                XCTAssertNotNil(normalizedMessage)
                
                expectation.fulfill()
                }.always {
                    // Noop
                }.error { error2 -> Void in
                    XCTFail("Could not retrieve Normalized actions. Reason \(error2)")
                }
            }.always {
                // Noop for now
            }.error { error -> Void in
                XCTFail("Could not send Actions \(error)")
            }
        
        self.waitForExpectationsWithTimeout(testTimeout, handler: nil)
    }

}
