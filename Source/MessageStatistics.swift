//
//  MessageStatistics.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 8/31/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper

open class MessageStatistics: Mappable {
    public var count: Int64?
    public var min: Double?
    public var max: Double?
    public var mean: Double?
    public var sum: Double?
    public var variance: Double?
    public var ts: ArtikTimestamp?
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        count <- map["count"]
        min <- map["min"]
        max <- map["max"]
        mean <- map["mean"]
        sum <- map["sum"]
        variance <- map["variance"]
        ts <- map["ts"]
    }
}
