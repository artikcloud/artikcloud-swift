//
//  UsersAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/8/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

open class UsersAPI {
    
    // MARK: - Self
    
    /// Get the current User's profile.
    ///
    /// - Returns: A `Promise<User>`
    open class func getSelf() -> Promise<User> {
        let promise = Promise<User>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/self"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let user = User(JSON: data) {
                promise.fulfill(user)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Application Properties
    
    /// Get a user's application properties
    ///
    /// - Parameter uid: The User's id.
    /// - Returns: A `Promise<JSONResponse>`
    open class func getApplicationProperties(uid: String) -> Promise<JSONResponse> {
        let promise = Promise<JSONResponse>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/properties"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let properties = data["properties"] as? JSONResponse {
                promise.fulfill(properties)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Create application properties for a User.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - aid: (Optional) The application id.
    ///   - properties: The desired application properties.
    /// - Returns: A `Promise<Void>`
    open class func createApplicationProperties(uid: String, aid: String? = nil, properties: [String:Any]) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/properties"
        
        if let clientID = aid ?? ArtikCloudSwiftSettings.clientID {
            let parameters: [String:Any] = [
                "uid": uid,
                "aid": clientID,
                "properties": properties
            ]
            
            APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.swiftyArtikSettings(reason: .noClientID))
        }
        return promise.promise
    }
    
    /// Update the application properties of a User.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - aid: (Optional) The application id.
    ///   - properties: The desired application properties.
    /// - Returns: A `Promise<Void>`
    open class func updateApplicationProperties(uid: String, aid: String? = nil, properties: [String:Any]) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/properties"
        
        if let clientID = aid ?? ArtikCloudSwiftSettings.clientID {
            let parameters: [String:Any] = [
                "uid": uid,
                "aid": clientID,
                "properties": properties
            ]
            
            APIHelpers.makeRequest(url: path, method: .put, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.swiftyArtikSettings(reason: .noClientID))
        }
        return promise.promise
    }
    
    /// Remove the application properties associated with a User.
    ///
    /// - Parameter uid: The User's id.
    /// - Returns: A `Promise<Void>`
    open class func removeApplicationProperties(uid: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/properties"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Devices
    /// Get a users devices using pagination.
    ///
    /// - Parameters:
    ///   - uid: The user's id
    ///   - count: The count of results, max 100.
    ///   - offset: The offset for pagination
    ///   - includeProperties: (Optional) Include Properties in results
    ///   - owner: (Optional) Restrict results to a `DeviceOwner`
    ///   - includeShareInfo: (Optional) Include Share Info in results
    ///   - includeDeviceTypeInfo: (Optional) Include Device Type Info in results
    /// - Returns: A `Promise<Page<Device>>`
    open class func getDevices(uid: String, count: Int, offset: Int = 0, includeProperties: Bool? = nil, owner: DevicesAPI.DeviceOwner? = nil, includeShareInfo: Bool? = nil, includeDeviceTypeInfo: Bool? = nil) -> Promise<Page<Device>> {
        return DevicesAPI.get(uid: uid, count: count, offset: offset, includeProperties: includeProperties, owner: owner, includeShareInfo: includeShareInfo, includeDeviceTypeInfo: includeDeviceTypeInfo)
    }
    
    /// Get all of a User's Devices using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - uid: The user's id
    ///   - includeProperties: (Optional) Include Properties in results
    ///   - owner: (Optional) Restrict results to a `DeviceOwner`
    ///   - includeShareInfo: (Optional) Include Share Info in results
    ///   - includeDeviceTypeInfo: (Optional) Include Device Type Info in results
    /// - Returns: A `Promise<Page<Device>>`
    open class func getDevices(uid: String, includeProperties: Bool? = nil, owner: DevicesAPI.DeviceOwner? = nil, includeShareInfo: Bool? = nil, includeDeviceTypeInfo: Bool? = nil) -> Promise<Page<Device>> {
        return DevicesAPI.get(uid: uid, includeProperties: includeProperties, owner: owner, includeShareInfo: includeShareInfo, includeDeviceTypeInfo: includeDeviceTypeInfo)
    }
    
    // MARK: - Device Types
    
    /// Get Device Types owned by a `User`
    ///
    /// - Parameters:
    ///   - uid: the `User`'s id
    ///   - count: The count of results, max 100
    ///   - offset: The offset for pagination
    ///   - name: (Optional) Filter results using a name query
    ///   - includeOrganization: Include `User`'s organization's Device Types in response, default: false
    /// - Returns: Promise<Page<DeviceType>>
    open class func getDeviceTypes(uid: String, count: Int, offset: Int = 0, name: String? = nil, includeOrganization: Bool = false) -> Promise<Page<DeviceType>> {
        return DeviceTypesAPI.get(uid: uid, count: count, offset: offset, name: name, includeOrganization: includeOrganization)
    }
    
    // MARK: - Rules
    
    /// Get a User's Rules using pagination.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - count: The course of results, max 100
    ///   - offset: The offset for pagination, default `0`.
    ///   - scope: The ownership scope of the Rules, default `.publicOrOwned`.
    ///   - excludeDisabled: Exclude disabled Rules from the results, default `false`.
    /// - Returns: A `Promise<Page<Rule>>`
    open class func getRules(uid: String, count: Int, offset: Int = 0, scope: RulesAPI.RuleScope = .publicOrOwned, excludeDisabled: Bool = false) -> Promise<Page<Rule>> {
        return RulesAPI.get(uid: uid, count: count, offset: offset, scope: scope, excludeDisabled: excludeDisabled)
    }
    
    /// Get all of a User's Rules using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - scope: The ownership scope of the Rules, default `.publicOROwned`.
    ///   - excludeDisabled: Exclude disabled Rules from the results, default `false`.
    /// - Returns: A `Promise<Page<Rule>>`
    open class func getRules(uid: String, scope: RulesAPI.RuleScope = .publicOrOwned, excludeDisabled: Bool = false) -> Promise<Page<Rule>> {
        return RulesAPI.get(uid: uid, scope: scope, excludeDisabled: excludeDisabled)
    }
    
    // MARK: - Scenes
    
    /// Get all of a User's Scenes using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameter uid: The User's id.
    /// - Returns: A `Promise<Page<Scene>>`
    open class func getScenes(uid: String) -> Promise<Page<Scene>> {
        return ScenesAPI.get(uid: uid)
    }
    
    // MARK: - Subscriptions
    
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
    open class func createSubscription(uid: String, sdtid: String? = nil, sdid: String? = nil, description: String? = nil, includeSharedDevices: Bool = false, callback: String) -> Promise<Subscription> {
        return SubscriptionsAPI.create(uid: uid, sdtid: sdtid, sdid: sdid, description: description, includeSharedDevices: includeSharedDevices, callback: callback)
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
    open class func createSubscription(uid: String, sdtid: String? = nil, sdid: String? = nil, description: String? = nil, includeSharedDevices: Bool = false, awsKey: String, awsSecret: String, awsRegion: String, awsKinesisStream: String) -> Promise<Subscription> {
        return SubscriptionsAPI.create(uid: uid, sdtid: sdtid, sdid: sdid, description: description, includeSharedDevices: includeSharedDevices, awsKey: awsKey, awsSecret: awsSecret, awsRegion: awsRegion, awsKinesisStream: awsKinesisStream)
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
    open class func createSubscription(uid: String, ddid: String, description: String? = nil, includeSharedDevices: Bool = false, callback: String) -> Promise<Subscription> {
        return SubscriptionsAPI.create(uid: uid, ddid: ddid, description: description, includeSharedDevices: includeSharedDevices, callback: callback)
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
    open class func createSubscription(uid: String, ddid: String, description: String? = nil, includeSharedDevices: Bool = false, awsKey: String, awsSecret: String, awsRegion: String, awsKinesisStream: String) -> Promise<Subscription> {
        return SubscriptionsAPI.create(uid: uid, ddid: ddid, description: description, includeSharedDevices: includeSharedDevices, awsKey: awsKey, awsSecret: awsSecret, awsRegion: awsRegion, awsKinesisStream: awsKinesisStream)
    }
    
}
