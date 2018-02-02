//
//  TokenValidation.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 9/8/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper

open class TokenValidation: Mappable {
    public var did: String?
    public var uid: String?
    public var cid: String?
    public var expiresIn: Int64?
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        did <- map["device_id"]
        uid <- map["user_id"]
        cid <- map["client_id"]
        expiresIn <- map["expires_in"]
    }
}
