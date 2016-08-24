//
//  TokensApiTests.swift
//  ArtikCloudClient
//
//  Created by Maneesh Sahu-SSI on 8/24/16.
//  Copyright © 2016 Samsung Strategy and Innovation Center. All rights reserved.
//

import ArtikCloudSwift
import XCTest
import PromiseKit
@testable import ArtikCloudClient

class TokensApiTests: ArtikCloudTests {
    let testTimeout = 100.0
    
    override func setUp() {
        super.setUp()

        ArtikCloudAPI.customHeaders["Authorization"] = "Bearer " + getProperty(key: "user1.token")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTokenInfo() {
        let expectation = self.expectationWithDescription("testTokenInfo")
        
        TokensAPI.tokenInfo().then { tokensInfoEnvelope -> Void in
                XCTAssertNotNil(tokensInfoEnvelope.data, "Tokens Info Data must not be nil")
                XCTAssertNotNil(tokensInfoEnvelope.data?.expiresIn, "ExpiresIn must not be nil")
            
                expectation.fulfill()
            }.always {
                // Noop for now
            }.error { error -> Void in
                XCTFail("Could not retrieve Token Info \(error)")
            }
        
        self.waitForExpectationsWithTimeout(testTimeout, handler: nil)
    }
    
    
}
