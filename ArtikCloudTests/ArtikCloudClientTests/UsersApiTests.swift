//
//  ArtikCloudClientTests.swift
//  ArtikCloudClientTests
//
//  Created by Maneesh Sahu-SSI on 4/4/16.
//  Copyright © 2016 Samsung Strategy and Innovation Center. All rights reserved.
//

import ArtikCloudSwift
import XCTest
import PromiseKit
@testable import ArtikCloudClient

class UsersApiTests: ArtikCloudTests {
    let testTimeout = 100.0
    
    override func setUp() {
        super.setUp()
        
        
        ArtikCloudAPI.customHeaders["Authorization"] = "Bearer " + getProperty(key: "user1.token")
        
    
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetSelf() {
        let expectation = self.expectationWithDescription("testGetSelf")
        
        UsersAPI.getSelf().then { userEnvelope -> Void in
                XCTAssertNotNil(userEnvelope.data, "User Data must not be nil")
                XCTAssert(userEnvelope.data?.name == self.getProperty(key: "user1.name"), "Incorrect name")
                XCTAssert(userEnvelope.data?.fullName == self.getProperty(key: "user1.fullname"), "Incorrect full name")
            
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
        UsersAPI.getUserDevices(userId: self.getProperty(key: "user1.id"), offset: nil, count: nil, includeProperties: true).then { envelope -> Void in
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
