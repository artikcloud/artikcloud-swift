//
//  DeviceManagementProperties.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 1/12/18.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class DeviceManagementProperties: Mappable {
    public var serverProperties: [String:Any]?
    public var systemProperties: [String:Any]?
    public var deviceProperties: [String:Any]?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        serverProperties <- map["serverProperties"]
        systemProperties <- map["systemProperties"]
        deviceProperties <- map["deviceProperties"]
    }
}
