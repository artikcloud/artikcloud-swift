//
//  ManifestProperties.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/9/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

open class ManifestProperties: Mappable {
    public var version: Int64?
    public var fields: [String:Any]? // FIXME: Parse into instances
    public var actions: [String:Any]? // FIXME: Parse into instances
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        version <- map["version"]
        fields <- map["properties.fields"]
        actions <- map["properties.actions"]
    }
}
