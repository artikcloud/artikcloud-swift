//
//  ArtikCloudClientTests.swift
//  ArtikCloudClientTests
//
//  Created by Maneesh Sahu-SSI on 4/4/16.
//  Copyright © 2016 Samsung Strategy and Innovation Center. All rights reserved.
//

import ArtikCloud
import XCTest
import PromiseKit
@testable import ArtikCloudClient

class UsersApiTests: XCTestCase {
    
    let testTimeout = 10.0
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetSelf() {
        let expectation = self.expectationWithDescription("testGetSelf")
        
        ArtikCloudAPI.customHeaders["Authorization"] = "Bearer 76a15b2f29e741eeb407d3891a7aa222"
        
        UsersAPI.getSelf().then { userEnvelope -> Void in
                XCTAssertNotNil(userEnvelope.data, "User Data must not be nil")
                XCTAssert(userEnvelope.data?.name == "maneesh", "Incorrect name")
                XCTAssert(userEnvelope.data?.fullName == "Maneesh Sahu", "Incorrect full name")
            
                expectation.fulfill()
            }.always {
                // Noop for now
            }.error { error -> Void in
                XCTFail("Could not retrieve User Profile")
        }
        
        self.waitForExpectationsWithTimeout(testTimeout, handler: nil)
    }
    
    func testGetUserDeviceTypes() {
        let expectation = self.expectationWithDescription("testGetUserDeviceTypes")
        ArtikCloudAPI.customHeaders["Authorization"] = "Bearer 76a15b2f29e741eeb407d3891a7aa222"
        
        UsersAPI.getUserDevices(userId: "04ddbd35d57d4d7b8f07f219c44457b2", offset: nil, count: nil, includeProperties: true).then { envelope -> Void in
                XCTAssertNotNil(envelope.data, "User Devices Envelope must not be nil")
            
                expectation.fulfill()
            }.always {
                // Noop
            }.error { error -> Void in
                XCTFail("Could not retrieve User Device Types")
        }
        
        self.waitForExpectationsWithTimeout(testTimeout, handler: nil)
    }
    

    
}
