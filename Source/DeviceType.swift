//
//  DeviceType.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/8/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class DeviceType: Mappable, PullableArtikInstance {
    public var id: String?
    public var uniqueName: String?
    public var latestVersion: Int32?
    public var lastUpdated: ArtikTimestamp?
    public var name: String?
    public var description: String?
    public var uid: String?
    public var oid: String?
    public var hasCloudConnector: Bool?
    public var approved: Bool?
    public var published: Bool?
    public var protected: Bool?
    public var inStore: Bool?
    public var ownedByCurrentUser: Bool?
    public var tags: [DeviceTypeTag]?
    public var rsp: Bool?
    public var issuerDn: String?
    public var vid: String?
    
    public class DeviceTypeTag: Mappable {
        public var name: String?
        public var isCategory: Bool?
        
        public required init?(map: Map) {}
        
        public func mapping(map: Map) {
            name <- map["name"]
            isCategory <- map["isCategory"]
        }
    }
    
    required public init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        uniqueName <- map["uniqueName"]
        latestVersion <- map["latestVersion"]
        lastUpdated <- map["lastUpdated"]
        name <- map["name"]
        description <- map["description"]
        uid <- map["uid"]
        oid <- map["oid"]
        hasCloudConnector <- map["hasCloudConnector"]
        approved <- map["approved"]
        published <- map["published"]
        protected <- map["protected"]
        inStore <- map["inStore"]
        ownedByCurrentUser <- map["ownedByCurrentUser"]
        tags <- map["tags"]
        rsp <- map["rsp"]
        issuerDn <- map["issuerDn"]
        vid <- map["vid"]
    }
    
    // MARK: - Manifest Properties
    
    public func getManifestProperties(version: Int64? = nil) -> Promise<ManifestProperties> {
        let (promise, resolver) = Promise<ManifestProperties>.pending()
        
        if let id = id {
            DeviceTypesAPI.getManifestProperties(id: id, version: version).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }

    public func getManifestVersions() -> Promise<[Int64]> {
        let (promise, resolver) = Promise<[Int64]>.pending()
        
        if let id = id {
            DeviceTypesAPI.getManifestVersions(id: id).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - Monetization
    
    public func getTiers(dtid: String, latest: Bool? = nil, status: MonetizationAPI.PricingTiersDetailsStatus? = nil) -> Promise<[PricingTiersDetails]> {
        let (promise, resolver) = Promise<[PricingTiersDetails]>.pending()
        
        if let id = id {
            MonetizationAPI.getTiers(dtid: id, latest: latest, status: status).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - Subscriptions
    
    public func createSubscription(uid: String, description: String? = nil, includeSharedDevices: Bool = false, callback: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        
        if let id = id {
            SubscriptionsAPI.create(uid: uid, sdtid: id, description: description, includeSharedDevices: includeSharedDevices, callback: callback).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func createSubscription(uid: String, description: String? = nil, includeSharedDevices: Bool = false, awsKey: String, awsSecret: String, awsRegion: String, awsKinesisStream: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        
        if let id = id {
            SubscriptionsAPI.create(uid: uid, sdtid: id, description: description, includeSharedDevices: includeSharedDevices, awsKey: awsKey, awsSecret: awsSecret, awsRegion: awsRegion, awsKinesisStream: awsKinesisStream).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - PullableArtikInstance
    
    public func pullFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            DeviceTypesAPI.get(id: id).done { type in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: type.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
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
