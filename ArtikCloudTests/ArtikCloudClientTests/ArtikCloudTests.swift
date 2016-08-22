//
//  ArtikCloudTests.swift
//  ArtikCloudClient
//
//  Created by Maneesh Sahu-SSI on 8/19/16.
//  Copyright © 2016 Samsung Strategy and Innovation Center. All rights reserved.
//

import XCTest

class ArtikCloudTests: XCTestCase {
    var properties: NSDictionary = [String:String]()
    
    override func setUp() {
        super.setUp()
        
        if let path = NSBundle(forClass:object_getClass(self)).pathForResource("artik", ofType: "properties") {
            do {
                let propertyFileContent = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                NSLog(propertyFileContent as String)
                
                let properties = propertyFileContent.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                

                let result = NSMutableDictionary(capacity: properties.count)
                for propertyString in properties {
                    let property = propertyString.componentsSeparatedByString("=")
                    if (property.count == 2) {
                        result.setObject(property[1], forKey: property[0])
                    }
                }
                self.properties = result
                
            } catch {
               print("Error loading artik.properties")
            }
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func getProperty(key key: String) -> String {
        return self.properties.objectForKey(key) as! String
    }
    
    func testProperty() {
        let userId = getProperty(key: "user1.id")
        XCTAssertTrue(userId == "04ddbd35d57d4d7b8f07f219c44457b2")
    }
    
}
