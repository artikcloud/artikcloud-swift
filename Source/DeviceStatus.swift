//
//  DeviceStatus.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/2/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class DeviceStatus: Mappable, AccessibleArtikInstance {
    public var did: String?
    public var lastMessageTs: ArtikTimestamp?
    public var lastActionTs: ArtikTimestamp?
    public var lastTimeOnline: ArtikTimestamp?
    public var availability: DeviceStatusAvailability?
    public var snapshot: [String:Any]?
    
    public enum DeviceStatusAvailability: String {
        case online = "online"
        case offline = "offline"
        case unknown = "unknown"
    }
    
    public init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        did <- map["did"]
        lastMessageTs <- map["data.lastMessageTs"]
        lastActionTs <- map["data.lastActionTs"]
        lastTimeOnline <- map["data.lastTimeOnline"]
        availability <- map["data.availability"]
        snapshot <- map["data.snapshot"]
    }
    
    // MARK: - AccessibleArtikInstance
    
    public func updateOnArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let did = did {
            if let availability = availability {
                DevicesAPI.updateStatus(id: did, to: availability).done {
                    resolver.fulfill(())
                }.catch { error -> Void in
                    resolver.reject(error)
                }
            } else {
                resolver.reject(ArtikError.missingValue(reason: .noAvailability))
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func pullFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let did = did {
            DevicesAPI.getStatus(id: did).done { status in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: status.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
}
