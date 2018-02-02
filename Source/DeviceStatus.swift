//
//  DeviceStatus.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/2/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
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
        let promise = Promise<Void>.pending()
        
        if let did = did {
            if let availability = availability {
                DevicesAPI.updateStatus(id: did, to: availability).then { _ -> Void in
                    promise.fulfill(())
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.reject(ArtikError.missingValue(reason: .noAvailability))
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func pullFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let did = did {
            DevicesAPI.getStatus(id: did).then { status -> Void in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: status.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
}
