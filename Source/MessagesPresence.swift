//
//  MessagesPresence.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 8/31/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
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
                return value.flatMap {
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
        let promise = Promise<Void>.pending()
        
        if let startDate = startDate {
            if let endDate = endDate {
                if let interval = interval {
                    MessagesAPI.getPresence(sdid: sdid, fieldPresence: fieldPresence, startDate: startDate, endDate: endDate, interval: interval).then { result -> Void in
                        self.mapping(map: Map(mappingType: .fromJSON, JSON: result.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                        promise.fulfill(())
                    }.catch { error -> Void in
                        promise.reject(error)
                    }
                } else {
                    promise.reject(ArtikError.missingValue(reason: .noInterval))
                }
            } else {
                promise.reject(ArtikError.missingValue(reason: .noEndDate))
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noStartDate))
        }
        return promise.promise
    }
}
