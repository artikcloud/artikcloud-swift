//
//  User.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/8/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class User: NSObject, NSCoding, Mappable {
    public var id: String?
    public var email: String?
    public var fullName: String?
    public var createdOn: ArtikTimestamp?
    public var modifiedOn: ArtikTimestamp?
    
    struct PropertyKey {
        static let id_key = "_id"
        static let email_key = "_email"
        static let fullName_key = "_fullName"
        static let createdOn_key = "_createdOn"
        static let modifiedOn_key = "_modifiedOn"
    }
    
    fileprivate override init() {
        super.init()
    }
    
     public init(id: String?, email: String?, fullname: String?, createdOn: ArtikTimestamp?, modifiedOn: ArtikTimestamp?) {
        super.init()
        self.id = id
        self.email = email
        self.fullName = fullname
        self.createdOn = createdOn
        self.modifiedOn = modifiedOn
    }
    
    // MARK: - Mappable 
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        fullName <- map["fullName"]
        createdOn <- map["createdOn"]
        modifiedOn <- map["modifiedOn"]
    }
    
    // MARK: - NSCoding
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.id_key)
        aCoder.encode(email, forKey: PropertyKey.email_key)
        aCoder.encode(fullName, forKey: PropertyKey.fullName_key)
        aCoder.encode(createdOn, forKey: PropertyKey.createdOn_key)
        aCoder.encode(modifiedOn, forKey: PropertyKey.modifiedOn_key)
    }
    
    required convenience public init(coder aDecoder: NSCoder) {
        self.init()
        self.id = aDecoder.decodeObject(forKey: PropertyKey.id_key) as? String
        self.email = aDecoder.decodeObject(forKey: PropertyKey.email_key) as? String
        self.fullName = aDecoder.decodeObject(forKey: PropertyKey.fullName_key) as? String
        self.createdOn = aDecoder.decodeObject(forKey: PropertyKey.createdOn_key) as? Int64
        self.modifiedOn = aDecoder.decodeObject(forKey: PropertyKey.modifiedOn_key) as? Int64
    }
    
    // MARK: - Application Properties
    
    public func getApplicationProperties() -> Promise<JSONResponse> {
        let (promise, resolver) = Promise<JSONResponse>.pending()
        
        if let id = id {
            UsersAPI.getApplicationProperties(uid: id).done { response in
                resolver.fulfill(response)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func createApplicationProperties(properties: [String:Any]) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            UsersAPI.createApplicationProperties(uid: id, properties: properties).done {
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func updateApplicationProperties(properties: [String:Any]) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            UsersAPI.updateApplicationProperties(uid: id, properties: properties).done {
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func removeApplicationProperties() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            UsersAPI.removeApplicationProperties(uid: id).done {
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - Devices
    
    public func getDevices(count: Int, offset: Int = 0, includeProperties: Bool? = nil, owner: DevicesAPI.DeviceOwner? = nil, includeShareInfo: Bool? = nil, includeDeviceTypeInfo: Bool? = nil) -> Promise<Page<Device>> {
        let (promise, resolver) = Promise<Page<Device>>.pending()
        
        if let id = id {
            UsersAPI.getDevices(uid: id, count: count, offset: offset, includeProperties: includeProperties, owner: owner, includeShareInfo: includeShareInfo, includeDeviceTypeInfo: includeDeviceTypeInfo).done { page in
                resolver.fulfill(page)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func getDevices(includeProperties: Bool? = nil, owner: DevicesAPI.DeviceOwner? = nil, includeShareInfo: Bool? = nil, includeDeviceTypeInfo: Bool? = nil) -> Promise<Page<Device>> {
        let (promise, resolver) = Promise<Page<Device>>.pending()
        
        if let id = id {
            UsersAPI.getDevices(uid: id, includeProperties: includeProperties, owner: owner, includeShareInfo: includeShareInfo, includeDeviceTypeInfo: includeDeviceTypeInfo).done { page in
                resolver.fulfill(page)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func createDevice(dtid: String, name: String, manifestVersion: UInt64? = nil, manifestVersionPolicy: DevicesAPI.ManifestVersionPolicy? = nil) -> Promise<Device> {
        let (promise, resolver) = Promise<Device>.pending()
        
        if let id = id {
            DevicesAPI.create(uid: id, dtid: dtid, name: name, manifestVersion: manifestVersion, manifestVersionPolicy: manifestVersionPolicy).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - Device Types
    
    public func getDeviceTypes(count: Int, offset: Int = 0, name: String? = nil, includeOrganization: Bool = false) -> Promise<Page<DeviceType>> {
        let (promise, resolver) = Promise<Page<DeviceType>>.pending()
        
        if let id = id {
            UsersAPI.getDeviceTypes(uid: id, count: count, offset: offset, name: name, includeOrganization: includeOrganization).done { page in
                resolver.fulfill(page)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - Rules
    
    public func getRules(count: Int, offset: Int = 0, scope: RulesAPI.RuleScope = .publicOrOwned, excludeDisabled: Bool = false) -> Promise<Page<Rule>> {
        let (promise, resolver) = Promise<Page<Rule>>.pending()
        
        if let id = id {
            UsersAPI.getRules(uid: id, count: count, offset: offset, scope: scope, excludeDisabled: excludeDisabled).done { page in
                resolver.fulfill(page)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func getRules(scope: RulesAPI.RuleScope = .publicOrOwned, excludeDisabled: Bool = false) -> Promise<Page<Rule>> {
        let (promise, resolver) = Promise<Page<Rule>>.pending()
        
        if let id = id {
            UsersAPI.getRules(uid: id, scope: scope, excludeDisabled: excludeDisabled).done { page in
                resolver.fulfill(page)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - Scenes
    
    public func getScenes() -> Promise<Page<Scene>> {
        let (promise, resolver) = Promise<Page<Scene>>.pending()
        
        if let id = id {
            UsersAPI.getScenes(uid: id).done { page in
                resolver.fulfill(page)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - Subscriptions
    
    public func createSubscription(sdtid: String? = nil, sdid: String? = nil, description: String? = nil, includeSharedDevices: Bool = false, callback: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        
        if let id = id {
            UsersAPI.createSubscription(uid: id, sdtid: sdtid, sdid: sdid, description: description, includeSharedDevices: includeSharedDevices, callback: callback).done { subscription in
                resolver.fulfill(subscription)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func createSubscription(sdtid: String? = nil, sdid: String? = nil, description: String? = nil, includeSharedDevices: Bool = false, awsKey: String, awsSecret: String, awsRegion: String, awsKinesisStream: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        
        if let id = id {
            UsersAPI.createSubscription(uid: id, sdtid: sdtid, sdid: sdid, description: description, includeSharedDevices: includeSharedDevices, awsKey: awsKey, awsSecret: awsSecret, awsRegion: awsRegion, awsKinesisStream: awsKinesisStream).done { subscription in
                resolver.fulfill(subscription)
                }.catch { error -> Void in
                    resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func createSubscription(ddid: String, description: String? = nil, includeSharedDevices: Bool = false, callback: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        
        if let id = id {
            UsersAPI.createSubscription(uid: id, ddid: ddid, description: description, includeSharedDevices: includeSharedDevices, callback: callback).done { subscription in
                resolver.fulfill(subscription)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func createSubscription(ddid: String, description: String? = nil, includeSharedDevices: Bool = false, awsKey: String, awsSecret: String, awsRegion: String, awsKinesisStream: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        
        if let id = id {
            UsersAPI.createSubscription(uid: id, ddid: ddid, description: description, includeSharedDevices: includeSharedDevices, awsKey: awsKey, awsSecret: awsSecret, awsRegion: awsRegion, awsKinesisStream: awsKinesisStream).done { subscription in
                resolver.fulfill(subscription)
                }.catch { error -> Void in
                    resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func getSubscription(count: Int, offset: Int = 0) -> Promise<Page<Subscription>> {
        let (promise, resolver) = Promise<Page<Subscription>>.pending()
        
        if let id = id {
            SubscriptionsAPI.get(uid: id, count: count, offset: offset).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func getSubscription() -> Promise<Page<Subscription>> {
        let (promise, resolver) = Promise<Page<Subscription>>.pending()
        
        if let id = id {
            SubscriptionsAPI.get(uid: id).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
}
