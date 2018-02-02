//
//  RuleStatistics.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/15/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper

open class RuleStatistics: Mappable {
    public var countApply: Int64?
    public var lastApply: ArtikTimestamp?
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        countApply <- map["countApply"]
        lastApply <- map["lastApply"]
    }
}
