//
//  MessagesPresence.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 8/31/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class MessagesPresence: Mappable, PullableArtikInstance {
    public var sdid: String?
    public var fieldPresence: String?
    public var interval: MessagesAPI.MessageStatisticsInterval?
    public var startDate: ArtikTimestamp?
    public var endDate: ArtikTimestamp?
    public var data: [ArtikTimestamp]?
    
    class PresenceTimestampsTransform: TransformType {
        func transformFromJSON(_ value: Any?) -> [ArtikTimestamp]? {
            if let value = value as? [[String:ArtikTimestamp]] {
                return value.compactMap {
                    $0["startDate"]
                }
            }
            return nil
        }
        
        func transformToJSON(_ value: [ArtikTimestamp]?) -> Any? {
            if let value = value {
                return value.map {
                    ["startDate": $0]
                }
            }
            return nil
        }
    }
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        sdid <- map["sdid"]
        fieldPresence <- map["fieldPresence"]
        interval <- map["interval"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        data <- (map["data"], PresenceTimestampsTransform())
    }
    
    // MARK: - PullableArtikInstance
    
    public func pullFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let startDate = startDate {
            if let endDate = endDate {
                if let interval = interval {
                    MessagesAPI.getPresence(sdid: sdid, fieldPresence: fieldPresence, startDate: startDate, endDate: endDate, interval: interval).done { result in
                        self.mapping(map: Map(mappingType: .fromJSON, JSON: result.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                        resolver.fulfill(())
                    }.catch { error -> Void in
                        resolver.reject(error)
                    }
                } else {
                    resolver.reject(ArtikError.missingValue(reason: .noInterval))
                }
            } else {
                resolver.reject(ArtikError.missingValue(reason: .noEndDate))
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noStartDate))
        }
        return promise
    }
}
