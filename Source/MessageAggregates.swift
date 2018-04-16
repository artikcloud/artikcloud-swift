//
//  MessageAggregates.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 8/31/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class MessageAggregates: Mappable, PullableArtikInstance {
    public var sdid: String?
    public var startDate: ArtikTimestamp?
    public var endDate: ArtikTimestamp?
    public var field: String?
    public var data: [MessageStatistics]?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        sdid <- map["sdid"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        field <- map["field"]
        data <- map["data"]
    }
    
    // MARK: - PullableArtikInstance
    
    public func pullFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let sdid = sdid {
            if let startDate = startDate {
                if let endDate = endDate {
                    if let field = field {
                        MessagesAPI.getAggregates(sdid: sdid, startDate: startDate, endDate: endDate, field: field).done { result in
                            self.mapping(map: Map(mappingType: .fromJSON, JSON: result.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                            resolver.fulfill(())
                        }.catch { error -> Void in
                            resolver.reject(error)
                        }
                    } else {
                        resolver.reject(ArtikError.missingValue(reason: .noField))
                    }
                } else {
                    resolver.reject(ArtikError.missingValue(reason: .noEndDate))
                }
            } else {
                resolver.reject(ArtikError.missingValue(reason: .noStartDate))
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noSdid))
        }
        return promise
    }
    
}
