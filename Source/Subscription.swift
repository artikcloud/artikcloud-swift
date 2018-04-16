//
//  Subscription.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 9/5/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class Subscription: Mappable, PullableArtikInstance, RemovableArtikInstance {
    public var id: String?
    public var aid: String?
    public var messageType: MessagesAPI.MessageType?
    public var uid: String?
    public var description: String?
    public var subscriptionType: SubscriptionsAPI.SubscriptionType?
    public var status: SubscriptionsAPI.SubscriptionStatus?
    public var callbackURL: URL?
    public var awsKey: String?
    public var awsSecret: String?
    public var awsRegion: String?
    public var awsKinesisStream: String?
    public var createdOn: ArtikTimestamp?
    public var modifiedOn: ArtikTimestamp?
    
    public init() {}
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        aid <- map["aid"]
        messageType <- map["messageType"]
        uid <- map["uid"]
        description <- map["description"]
        subscriptionType <- map["subscriptionType"]
        status <- map["status"]
        callbackURL <- map["callbackUrl"]
        awsKey <- map["awsKey"]
        awsSecret <- map["awsSecret"]
        awsRegion <- map["awsRegion"]
        awsKinesisStream <- map["awsKinesisStream"]
        createdOn <- map["createdOn"]
        modifiedOn <- map["modifiedOn"]
    }
    
    public func confirm(aid: String? = nil, nonce: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        
        if let id = id {
            SubscriptionsAPI.confirm(sid: id, aid: aid, nonce: nonce).done { result in
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
            SubscriptionsAPI.get(sid: id).done { result in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: result.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - RemovableArtikInstance
    
    public func removeFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            SubscriptionsAPI.remove(sid: id).done { _ in
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
