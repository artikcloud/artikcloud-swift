//
//  SubscriptionsAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 9/5/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

open class SubscriptionsAPI {
    
    public enum SubscriptionType: String {
        case callback = "httpCallback"
        case awsKinesis = "awsKinesis"
    }
    
    public enum SubscriptionStatus: String {
        case active = "ACTIVE"
        case pendingCallbackValidation = "PENDING_CALLBACK_VALIDATION"
    }
    
    // MARK: - Create

    /// Create a Subscription to receive notifications of messages for a user's devices using an HTTP callback.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - sdtid: (Optional) Source device type ID to subscribe to.
    ///   - sdid: (Optional) Source device ID to subscribe to.
    ///   - description: (Optional) The description of the subscription.
    ///   - includeSharedDevices: Include Shared Devices in subscription.
    ///   - callback: The desired callback url.
    /// - Returns: A `Promise<Subscription>`
    open class func create(uid: String, sdtid: String? = nil, sdid: String? = nil, description: String? = nil, includeSharedDevices: Bool = false, callback: String) -> Promise<Subscription> {
        guard sdtid == nil || sdid == nil else {
            let (promise, resolver) = Promise<Subscription>.pending()
            resolver.reject(ArtikError.subscription(reason: .cannotUseBothSdtidAndSdid))
            return promise
        }
        return self._create(uid: uid, sdtid: sdtid, sdid: sdid, callback: callback, messageType: .message, description: description, includeSharedDevices: includeSharedDevices)
    }
    
    /// Create a Subscription to receive notifications of messages for a user's devices using an Amazon Kinesis Stream.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - sdtid: (Optional) Source device type ID to subscribe to.
    ///   - sdid: (Optional) Source device ID to subscribe to.
    ///   - description: (Optional) The description of the subscription.
    ///   - includeSharedDevices: Include Shared Devices in subscription.
    ///   - awsKey: Key of the AWS user/role with (write) access to the Amazon Kinesis stream.
    ///   - awsSecret: Secret of the AWS user/role with (write) access to the Amazon Kinesis stream.
    ///   - awsRegion: Region of the AWS user/role with (write) access to the Amazon Kinesis stream.
    ///   - awsKinesisStream: Stream name of the Amazon Kinesis stream.
    /// - Returns: A `Promise<Subscription>`
    open class func create(uid: String, sdtid: String? = nil, sdid: String? = nil, description: String? = nil, includeSharedDevices: Bool = false, awsKey: String, awsSecret: String, awsRegion: String, awsKinesisStream: String) -> Promise<Subscription> {
        guard sdtid == nil || sdid == nil else {
            let (promise, resolver) = Promise<Subscription>.pending()
            resolver.reject(ArtikError.subscription(reason: .cannotUseBothSdtidAndSdid))
            return promise
        }
        return self._create(uid: uid, sdtid: sdtid, sdid: sdid, awsKey: awsKey, awsSecret: awsSecret, awsRegion: awsRegion, awsKinesisStream: awsKinesisStream, messageType: .message, description: description, includeSharedDevices: includeSharedDevices)
    }
    
    /// Create a Subscription to receive notifications of actions for a user's devices using an HTTP callback.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - ddid: Destination device ID to subscribe to.
    ///   - description: (Optional) The description of the subscription.
    ///   - includeSharedDevices: Include Shared Devices in subscription.
    ///   - callback: The desired callback url.
    /// - Returns: A `Promise<Subscription>`
    open class func create(uid: String, ddid: String, description: String? = nil, includeSharedDevices: Bool = false, callback: String) -> Promise<Subscription> {
        return self._create(uid: uid, ddid: ddid, callback: callback, messageType: .action, description: description, includeSharedDevices: includeSharedDevices)
    }
    
    /// Create a Subscription to receive notifications of actions for a user's devices using an Amazon Kinesis Stream.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - ddid: Destination device ID to subscribe to.
    ///   - description: (Optional) The description of the subscription.
    ///   - includeSharedDevices: Include Shared Devices in subscription.
    ///   - awsKey: Key of the AWS user/role with (write) access to the Amazon Kinesis stream.
    ///   - awsSecret: Secret of the AWS user/role with (write) access to the Amazon Kinesis stream.
    ///   - awsRegion: Region of the AWS user/role with (write) access to the Amazon Kinesis stream.
    ///   - awsKinesisStream: Stream name of the Amazon Kinesis stream.
    /// - Returns: A `Promise<Subscription>`
    open class func create(uid: String, ddid: String, description: String? = nil, includeSharedDevices: Bool = false, awsKey: String, awsSecret: String, awsRegion: String, awsKinesisStream: String) -> Promise<Subscription> {
        return self._create(uid: uid, ddid: ddid, awsKey: awsKey, awsSecret: awsSecret, awsRegion: awsRegion, awsKinesisStream: awsKinesisStream, messageType: .action, description: description, includeSharedDevices: includeSharedDevices)
    }
    
    // MARK: - Remove
    
    /// Remove an existing Subscription.
    ///
    /// - Parameter sid: The Subscription's id.
    /// - Returns: A `Promise<Void>`
    open class func remove(sid: String) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/subscriptions/\(sid)"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).done { _ in
            resolver.fulfill(())
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Get
    
    /// Get an existing Subscription.
    ///
    /// - Parameter sid: The Subscription's id.
    /// - Returns: A `Promise<Subscription>`
    open class func get(sid: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/subscriptions/\(sid)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let subscription = Subscription(JSON: data) {
                resolver.fulfill(subscription)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get all Subscriptions for the current Application using pagination.
    ///
    /// - Parameters:
    ///   - uid: (Optional) The User's id.
    ///   - count: (Optional) The count of results, max 100.
    ///   - offset: (Optional) The offset for pagination, default `0`.
    /// - Returns: A `Promise<Page<Subscription>>`
    open class func get(uid: String? = nil, count: Int, offset: Int = 0) -> Promise<Page<Subscription>> {
        let (promise, resolver) = Promise<Page<Subscription>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/subscriptions"
        let parameters: [String:Any] = [
            "count": count,
            "offset": offset
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let offset = response["offset"] as? Int64, let total = response["total"] as? Int64, let count = response["count"] as? Int64, let subscriptions = response["data"] as? [[String:Any]] {
                let page = Page<Subscription>(offset: offset, total: total)
                guard subscriptions.count == Int(count) else {
                    resolver.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in subscriptions {
                    if let subscription = Subscription(JSON: item) {
                        page.data.append(subscription)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                resolver.fulfill(page)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get all Subscriptions for the current Application using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - uid: (Optional) The User's id.
    /// - Returns: A `Promise<Page<Subscription>>`
    open class func get(uid: String? = nil) -> Promise<Page<Subscription>> {
        return self.getRecursive(Page<Subscription>(), uid: uid, offset: 0)
    }
    
    // MARK: - Confirm
    
    /// Validates a subscription with ARTIK Cloud. If successful, subscription will be set to active status.
    ///
    /// - Parameters:
    ///   - sid: The Subscription's id.
    ///   - aid: (Optional) Application ID associated with the subscription.
    ///   - nonce: Nonce for authentication.
    /// - Returns: A `Promise<Subscription>`
    open class func confirm(sid: String, aid: String? = nil, nonce: String) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/subscriptions/\(sid)/validate"
        
        if let aid = aid ?? ArtikCloudSwiftSettings.clientID {
            let parameters = [
                "aid": aid,
                "nonce": nonce
            ]
            
            APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default, includeAuthHeader: false).done { response in
                if let data = response["data"] as? [String:Any], let subscription = Subscription(JSON: data) {
                    resolver.fulfill(subscription)
                } else {
                    resolver.reject(ArtikError.json(reason: .unexpectedFormat))
                }
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.artikCloudSwiftSettings(reason: .noClientID))
        }
        return promise
    }
    
    // MARK: - Private Methods
    
    private class func _create(uid: String, sdtid: String? = nil, sdid: String? = nil, ddid: String? = nil, callback: String? = nil, awsKey: String? = nil, awsSecret: String? = nil, awsRegion: String? = nil, awsKinesisStream: String? = nil, messageType: MessagesAPI.MessageType, description: String? = nil, includeSharedDevices: Bool? = nil) -> Promise<Subscription> {
        let (promise, resolver) = Promise<Subscription>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/subscriptions"
        let parameters = APIHelpers.removeNilParameters([
            "uid": uid,
            "sdtid": sdtid,
            "sdid": sdid,
            "ddid": ddid,
            "messageType": messageType.rawValue,
            "description": description,
            "includeSharedDevices": includeSharedDevices,
            "callbackUrl": callback,
            "awsKey": awsKey,
            "awsSecret": awsSecret,
            "awsRegion": awsRegion,
            "awsKinesisStream": awsKinesisStream
        ])
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let subscription = Subscription(JSON: data) {
                resolver.fulfill(subscription)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    private class func getRecursive(_ container: Page<Subscription>, uid: String? = nil, offset: Int = 0) -> Promise<Page<Subscription>> {
        let (promise, resolver) = Promise<Page<Subscription>>.pending()
        
        SubscriptionsAPI.get(uid: uid, count: 100, offset: offset).done { page in
            container.data.append(contentsOf: page.data)
            container.total = page.total
            
            if container.total > Int64(container.data.count) {
                self.getRecursive(container, uid: uid, offset: Int(page.offset) + page.data.count).done { page in
                    resolver.fulfill(page)
                }.catch { error -> Void in
                    resolver.reject(error)
                }
            } else {
                resolver.fulfill(container)
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
}
