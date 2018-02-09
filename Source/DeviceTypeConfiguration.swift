//
//  DeviceTypeConfiguration.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 1/12/18.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class DeviceTypeConfiguration: Mappable, AccessibleArtikInstance {
    public var dtid: String?
    public var devicePropertiesEnabled: Bool?
    public var pmin: Int64?
    public var pmax: Int64?
    public var taskExpiresAfter: Int64?
    public var createdOn: ArtikTimestamp?
    public var modifiedOn: ArtikTimestamp?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        dtid <- map["dtid"]
        devicePropertiesEnabled <- map["devicePropertiesEnabled"]
        pmin <- map["pmin"]
        pmax <- map["pmax"]
        taskExpiresAfter <- map["taskExpiresAfter"]
        createdOn <- map["createdOn"]
        modifiedOn <- map["modifiedOn"]
    }
    
    // MARK: - AccessibleArtikInstance
    
    public func pullFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let dtid = dtid {
            DeviceManagementAPI.getDeviceTypeConfiguration(dtid: dtid).then { result -> Void in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: result.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func updateOnArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let dtid = dtid {
            DeviceManagementAPI.setDeviceTypeConfiguration(dtid: dtid, devicePropertiesEnabled: devicePropertiesEnabled, pmin: pmin, pmax: pmax, taskExpiresAfter: taskExpiresAfter).then { _ -> Void in
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
