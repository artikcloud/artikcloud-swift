//
//  DeviceShare.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/31/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

open class DeviceShare: Mappable {
    public var id: String?
    public var email: String?
    public var status: DeviceShareStatus?
    public var sharedOn: ArtikTimestamp?
    
    public enum DeviceShareStatus: String {
        case accepted = "ACCEPTED"
        case rejected = "REJECTED"
        case pending = "PENDING"
    }
    
    public init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        status <- map["status"]
        sharedOn <- map["sharedOn"]
    }
}
