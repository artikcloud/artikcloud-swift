//
//  Subscription.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 9/5/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
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
        let promise = Promise<Subscription>.pending()
        
        if let id = id {
            SubscriptionsAPI.confirm(sid: id, aid: aid, nonce: nonce).then { result -> Void in
                promise.fulfill(result)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    // MARK: - PullableArtikInstance
    
    public func pullFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            SubscriptionsAPI.get(sid: id).then { result -> Void in
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
    
    // MARK: - RemovableArtikInstance
    
    public func removeFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            SubscriptionsAPI.remove(sid: id).then { _ -> Void in
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
