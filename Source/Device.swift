//
//  Device.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/8/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit
#if os(iOS)
import SafariServices
#endif

open class Device: Mappable, AccessibleArtikInstance, RemovableArtikInstance {
    public var id: String?
    public var uid: String?
    public var dtid: String?
    public var name: String?
    public var manifestVersion: Int64?
    public var manifestVersionPolicy: DevicesAPI.ManifestVersionPolicy?
    public var needProviderAuth: Bool?
    public var cloudAuthorization: DevicesAPI.CloudAuthorization?
    public var properties: [String:Any]?
    public var createdOn: ArtikTimestamp?
    public var connected: Bool?
    public var certificateInfo: [String:Any]?
    public var certificateSignature: String?
    public var eid: String?
    public var providerCredentials: [String:Any]?
    public var deviceTypeName: String?
    public var deviceTypeIsPublished: Bool?
    public var deviceTypeIsProtected: Bool?
    public var sharedWithMe: String?
    public var sharedWithOthers: Bool?
    
    required public init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        uid <- map["uid"]
        dtid <- map["dtid"]
        name <- map["name"]
        manifestVersion <- map["manifestVersion"]
        manifestVersionPolicy <- map["manifestVersionPolicy"]
        needProviderAuth <- map["needProviderAuth"]
        cloudAuthorization <- map["cloudAuthorization"]
        properties <- map["properties"]
        createdOn <- map["createdOn"]
        connected <- map["connected"]
        certificateInfo <- map["certificateInfo"]
        certificateSignature <- map["certificateSignature"]
        eid <- map["eid"]
        providerCredentials <- map["providerCredentials"]
        deviceTypeName <- map["deviceTypeName"]
        deviceTypeIsPublished <- map["deviceTypeIsPublished"]
        deviceTypeIsProtected <- map["deviceTypeIsProtected"]
        sharedWithMe <- map["sharedWithMe"]
        sharedWithOthers <- map["sharedWithOthers"]
    }
    
    // MARK: - Token
    
    public func getToken(createIfNone: Bool) -> Promise<DeviceToken> {
        let promise = Promise<DeviceToken>.pending()
        
        if let id = id {
            DevicesAPI.getToken(id: id, createIfNone: createIfNone).then { token -> Void in
                promise.fulfill(token)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func revokeToken() -> Promise<DeviceToken> {
        let promise = Promise<DeviceToken>.pending()
        
        if let id = id {
            DevicesAPI.revokeToken(id: id).then { token -> Void in
                promise.fulfill(token)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    // MARK: - Cloud Connector
    
    public func authorize() -> Promise<URLRequest> {
        let promise = Promise<URLRequest>.pending()
        
        if let id = id {
            DevicesAPI.authorize(id: id).then { request -> Void in
                promise.fulfill(request)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func unauthorize() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            DevicesAPI.unauthorize(id: id).then { _ -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func isCloudAuthorized() -> Bool {
        if let cloudAuthorization = cloudAuthorization {
            if cloudAuthorization == .unauthorized {
                return false
            }
        }
        return true
    }
    
    // MARK: - Status
    
    public func getStatus(includeSnapshot: Bool? = nil, includeSnapshotTimestamp: Bool? = nil) -> Promise<DeviceStatus> {
        let promise = Promise<DeviceStatus>.pending()
        
        if let id = id {
            DevicesAPI.getStatus(id: id, includeSnapshot: includeSnapshot, includeSnapshotTimestamp: includeSnapshotTimestamp).then { status -> Void in
                promise.fulfill(status)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func updateStatus(to value: DeviceStatus.DeviceStatusAvailability) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            DevicesAPI.updateStatus(id: id, to: value).then { _ -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    // MARK: - Sharing
    
    public func getShares(count: Int, offset: Int = 0) -> Promise<Page<DeviceShare>> {
        let promise = Promise<Page<DeviceShare>>.pending()
        
        if let id = id {
            DevicesAPI.getShares(id: id, count: count, offset: offset).then { page -> Void in
                promise.fulfill(page)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func getShares() -> Promise<Page<DeviceShare>> {
        let promise = Promise<Page<DeviceShare>>.pending()
        
        if let id = id {
            DevicesAPI.getShares(id: id).then { page -> Void in
                promise.fulfill(page)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func getShare(id: String) -> Promise<DeviceShare> {
        let promise = Promise<DeviceShare>.pending()
        
        if let did = self.id {
            DevicesAPI.getShare(id: did, sid: id).then { share -> Void in
                promise.fulfill(share)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func share(email: String) -> Promise<DeviceShare> {
        let promise = Promise<DeviceShare>.pending()
        
        if let id = id {
            DevicesAPI.share(id: id, email: email).then { share -> Void in
                promise.fulfill(share)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func unshare(id: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let did = self.id {
            DevicesAPI.unshare(id: did, sid: id).then { _ -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func isSharable() -> Bool {
        return (deviceTypeIsPublished ?? false) && (sharedWithMe == nil)
    }
    
    // MARK: - Monetization
    
    public func getUpgradeURL(action: MonetizationAPI.MonetizationUpgradeAction = .upgrade) -> Promise<URL> {
        let promise = Promise<URL>.pending()
        
        if let id = id {
            MonetizationAPI.getUpgradeURL(did: id, action: action).then { result -> Void in
                promise.fulfill(result)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    #if os(iOS)
    public func getUpgradeController(action: MonetizationAPI.MonetizationUpgradeAction = .upgrade) -> Promise<SFSafariViewController> {
        let promise = Promise<SFSafariViewController>.pending()
        
        if let id = id {
            MonetizationAPI.getUpgradeController(did: id, action: action).then { result -> Void in
                promise.fulfill(result)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    #endif
    
    public func getTiers(active: Bool? = nil) -> Promise<[PricingTier]> {
        let promise = Promise<[PricingTier]>.pending()
        
        if let id = id {
            MonetizationAPI.getTiers(did: id, active: active).then { result -> Void in
                promise.fulfill(result)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    // MARK: - AccessibleArtikInstance
    
    public func updateOnArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            DevicesAPI.update(id: id, name: name, manifestVersion: manifestVersion, manifestVersionPolicy: manifestVersionPolicy).then { _ -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func pullFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            DevicesAPI.get(id: id, includeProperties: true).then { device -> Void in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: device.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    // MARK: - RemovableArtikInstance
    
    public func removeFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            DevicesAPI.delete(id: id).then { _ -> Void in
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
