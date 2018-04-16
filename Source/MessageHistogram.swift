//
//  MessageHistogram.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 8/31/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class MessageHistogram: MessageAggregates {
    public var interval: MessagesAPI.MessageStatisticsInterval?
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        interval <- map["interval"]
    }
    
    // MARK: - PullableArtikInstance
    
    public override func pullFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let sdid = sdid {
            if let startDate = startDate {
                if let endDate = endDate {
                    if let interval = interval {
                        if let field = field {
                            MessagesAPI.getHistogram(sdid: sdid, startDate: startDate, endDate: endDate, interval: interval, field: field).done { result in
                                self.mapping(map: Map(mappingType: .fromJSON, JSON: result.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                                resolver.fulfill(())
                            }.catch { error -> Void in
                                resolver.reject(error)
                            }
                        } else {
                            resolver.reject(ArtikError.missingValue(reason: .noField))
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
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noSdid))
        }
        return promise
    }
    
}
