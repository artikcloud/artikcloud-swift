//
//  LimitedInputCode.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 9/6/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class LimitedInputCode: Mappable {
    public var deviceCode: String?
    public var userCode: String?
    public var verification: URL?
    public var expiresIn: Int64?
    public var interval: Int64?
    
    class VerificationURLTransform: TransformType {
        func transformFromJSON(_ value: Any?) -> URL? {
            if let value = value as? String {
                return URL(string: value)
            }
            return nil
        }
        
        func transformToJSON(_ value: URL?) -> Any? {
            if let value = value {
                return value.absoluteString
            }
            return nil
        }
    }
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        deviceCode <- map["device_code"]
        userCode <- map["user_code"]
        verification <- (map["verification_url"], VerificationURLTransform())
        expiresIn <- map["expires_in"]
        interval <- map["interval"]
    }
    
    public func pollForUserToken(attempts: UInt = 10) -> Promise<UserToken> {
        return AuthenticationAPI.pollForUserToken(using: self, attempts: attempts)
    }
}
