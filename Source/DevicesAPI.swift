//
//  DevicesAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/31/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

open class DevicesAPI {
    
    public enum DeviceOwner: String {
        case all = "ALL"
        case me = "ME"
        case sharedWithMe = "SHARED_WITH_ME"
    }
    
    public enum ManifestVersionPolicy: String {
        case latest = "LATEST"
        case device = "DEVICE"
    }
    
    public enum DeviceShareFilter: String {
        case all = "ALL"
        case waiting = "WAITING"
        case accepted = "ACCEPTED"
        case rejected = "REJECTED"
    }
    
    public enum CloudAuthorization: String {
        case none = "NO_AUTHORIZATION"
        case authorized = "AUTHORIZED"
        case unauthorized = "UNAUTHORIZED"
    }
    
    // MARK: - Main Methods
    
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
    open class func get(uid: String, count: Int, offset: Int = 0, includeProperties: Bool? = nil, owner: DeviceOwner? = nil, includeShareInfo: Bool? = nil, includeDeviceTypeInfo: Bool? = nil) -> Promise<Page<Device>> {
        let promise = Promise<Page<Device>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/devices"
        let parameters = APIHelpers.removeNilParameters([
            "count": count,
            "offset": offset,
            "includeProperties": includeProperties,
            "owner": owner?.rawValue,
            "includeShareInfo": includeShareInfo,
            "dt_name": includeDeviceTypeInfo
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let devices = (response["data"] as? [String:Any])?["devices"] as? [[String:Any]] {
                let page = Page<Device>(offset: offset, total: total)
                if devices.count != Int(count) {
                    promise.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in devices {
                    if let device = Device(JSON: item) {
                        page.data.append(device)
                    } else {
                        promise.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                promise.fulfill(page)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
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
    open class func get(uid: String, includeProperties: Bool? = nil, owner: DeviceOwner? = nil, includeShareInfo: Bool? = nil, includeDeviceTypeInfo: Bool? = nil) -> Promise<Page<Device>> {
        return getRecursive(Page<Device>(), uid: uid, includeProperties: includeProperties, owner: owner, includeShareInfo: includeShareInfo, includeDeviceTypeInfo: includeDeviceTypeInfo)
    }
    
    /// Get a specific Device.
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - includeProperties: Include the Device's Properties in the response
    /// - Returns: A `Promise<Device>`
    open class func get(id: String, includeProperties: Bool = false) -> Promise<Device> {
        let promise = Promise<Device>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)"
        let parameters: [String:Any]? = includeProperties ? ["includeProperties": true] : nil
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: includeProperties ? URLEncoding.queryString : URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let device = Device(JSON: data) {
                promise.fulfill(device)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Create a new device for a user.
    ///
    /// - Parameters:
    ///   - uid: The user's id
    ///   - dtid: The device type's id
    ///   - name: The name of the new device
    ///   - manifestVersion: (Optional) The desired manifest version
    ///   - manifestVersionPolicy: (Optional) The desired manifest version policy
    /// - Returns: A `Promise<Device>`
    open class func create(uid: String, dtid: String, name: String, manifestVersion: UInt64? = nil, manifestVersionPolicy: ManifestVersionPolicy? = nil) -> Promise<Device> {
        let promise = Promise<Device>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices"
        let parameters = APIHelpers.removeNilParameters([
            "uid": uid,
            "dtid": dtid,
            "name": name,
            "manifestVersion": manifestVersion,
            "manifestVersionPolicy": manifestVersionPolicy?.rawValue
        ])
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let device = Device(JSON: data) {
                promise.fulfill(device)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    
    /// Update a Device.
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - name: (Optional) The Device's new name
    ///   - manifestVersion: (Optional) The Device's new manifest version
    ///   - manifestVersionPolicy: (Optional) The Device's new manifest version policy
    /// - Returns: A `Promise<Device>`
    open class func update(id: String, name: String? = nil, manifestVersion: Int64? = nil, manifestVersionPolicy: ManifestVersionPolicy? = nil) -> Promise<Device> {
        let promise = Promise<Device>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)"
        
        let parameters = APIHelpers.removeNilParameters([
            "name": name,
            "manifestVersion": manifestVersion,
            "manifestVersionPolicy": manifestVersionPolicy?.rawValue
        ])
        guard parameters.count > 0 else {
            self.get(id: id).then { result -> Void in
                promise.fulfill(result)
            }.catch { error -> Void in
                promise.reject(error)
            }
            return promise.promise
        }
        
        APIHelpers.makeRequest(url: path, method: .put, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let device = Device(JSON: data) {
                promise.fulfill(device)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Remove a Device from ARTIK Cloud.
    ///
    /// - Parameter id: The Device's id
    /// - Returns: A `Promise<Void>`
    open class func delete(id: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Device Token
    
    /// Get a Device's Token. More info:
    /// https://developer.artik.cloud/documentation/getting-started/access-tokens.html#device-token
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - createIfNone: Create the `DeviceToken` if it does not exist
    /// - Returns: A `Promise<DeviceToken>`
    open class func getToken(id: String, createIfNone: Bool) -> Promise<DeviceToken> {
        let promise = Promise<DeviceToken>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/tokens"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let token = DeviceToken(JSON: data) {
                promise.fulfill(token)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            if createIfNone, let error = error as? ArtikError, case .responseError(let nestedError, _) = error, let code = (nestedError as? AFError)?.responseCode, code == 404 {
                APIHelpers.makeRequest(url: path, method: .put, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
                    if let data = response["data"] as? [String:Any], let token = DeviceToken(JSON: data) {
                        promise.fulfill(token)
                    } else {
                        promise.reject(ArtikError.json(reason: .unexpectedFormat))
                    }
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.reject(error)
            }
        }
        return promise.promise
    }
    
    /// Revoke a Device's Token.
    ///
    /// - Parameter id: The Device's id
    /// - Returns: A `Promise<DeviceToken>` returning the removed token
    open class func revokeToken(id: String) -> Promise<DeviceToken> {
        let promise = Promise<DeviceToken>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/tokens"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let token = DeviceToken(JSON: data) {
                promise.fulfill(token)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Cloud Connector
    
    /// Get a URLRequest to present to the user requesting to authenticate and authorize a Cloud Connector.
    /// When the user finishes, your `redirectURI` will be called back, use 
    /// `ArtikCloudSwiftSettings.identifyRedirectEndpoint(_ callback: URL)` and handle its `.cloudAuthorization` case.
    ///
    /// - Parameters:
    ///   - id: The Device's id
    /// - Returns: A `Promise<URLRequest>`
    open class func authorize(id: String) -> Promise<URLRequest> {
        let promise = Promise<URLRequest>.pending()
        
        guard let referer = ArtikCloudSwiftSettings.getRedirectURI(for: .cloudAuthorization) else {
            promise.reject(ArtikError.artikCloudSwiftSettings(reason: .noRedirectURI))
            return promise.promise
        }
        
        ArtikCloudSwiftSettings.getUserToken().then { token -> Void in
            if let token = token {
                let headers = [
                    APIHelpers.authorizationHeaderKey: token.getHeaderValue(),
                    "cache-control": "no-cache",
                    "referer": referer
                ]
                
                if let url = URL(string: "\(ArtikCloudSwiftSettings.basePath)/devices/\(id)/providerauth?mobile=true") {
                    var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
                    request.httpMethod = "POST"
                    request.allHTTPHeaderFields = headers
                    promise.fulfill(request)
                } else {
                    promise.reject(ArtikError.url(reason: .failedToInit))
                }
            } else {
                promise.reject(ArtikError.artikCloudSwiftSettings(reason: .noUserToken))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Unauthorize a Cloud Connector's access.
    ///
    /// - Parameter id: The Device's id
    /// - Returns: A `Promise<Void>`
    open class func unauthorize(id: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/providerauth"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).then { _ -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Device Status
    
    /// Get a Device's Status.
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - includeSnapshot: (Optional) Include the device's snapshot in the response
    ///   - includeSnapshotTimestamp: (Optional) Include timestamps in the device's snapshot, if included
    /// - Returns: A `Promise<DeviceStatus>`
    open class func getStatus(id: String, includeSnapshot: Bool? = nil, includeSnapshotTimestamp: Bool? = nil) -> Promise<DeviceStatus> {
        let promise = Promise<DeviceStatus>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/status"
        let parameters = APIHelpers.removeNilParameters([
            "includeSnapshot": includeSnapshot,
            "includeSnapshotTimestamp": includeSnapshotTimestamp
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let status = DeviceStatus(JSON: response) {
                promise.fulfill(status)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get Devices' Statuses using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - ids: The Devices' ids
    ///   - includeSnapshot: (Optional) Include the devices' snapshot in the response
    ///   - includeSnapshotTimestamp: (Optional) Include timestamps in the devices' snapshot, if included
    /// - Returns: A `Promise<Page<DeviceStatus>>`
    open class func getStatuses(ids: [String], includeSnapshot: Bool? = nil, includeSnapshotTimestamp: Bool? = nil) -> Promise<Page<DeviceStatus>> {
        let parameters = APIHelpers.removeNilParameters([
            "includeSnapshot": includeSnapshot,
            "includeSnapshotTimestamp": includeSnapshotTimestamp
        ])
        return getStatusesRecursive(Page<DeviceStatus>(), ids: ids, parameters: parameters)
    }
    
    /// Update a Device's Availability.
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - value: The new availability value
    /// - Returns: A `Promise<Void>`
    open class func updateStatus(id: String, to value: DeviceStatus.DeviceStatusAvailability) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/status"
        let parameters = [
            "availability": value.rawValue
        ]
        
        APIHelpers.makeRequest(url: path, method: .put, parameters: parameters, encoding: JSONEncoding.default).then { _ -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Device Sharing
    
    /// Get a Device's Shares using pagination.
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - count: The number of shares in the response
    ///   - offset: The offset of the pagination
    /// - Returns: A `Promise<Page<DeviceShare>>`
    open class func getShares(id: String, count: Int, offset: Int = 0) -> Promise<Page<DeviceShare>> {
        let promise = Promise<Page<DeviceShare>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/shares"
        let parameters: [String:Any] = [
            "count": count,
            "offset": offset
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            do {
                let page = try paginatedDeviceSharesToInstance(response)
                promise.fulfill(page)
            } catch {
                promise.reject(error)
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get all of a Device's Shares using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameter id: The Device's id
    /// - Returns: A `Promise<Page<DeviceShare>>`
    open class func getShares(id: String) -> Promise<Page<DeviceShare>> {
        return getSharesRecursive(Page<DeviceShare>(), id: id, offset: 0)
    }
    
    /// Get a user's Device Shares using pagination.
    ///
    /// - Parameters:
    ///   - uid: The user's id
    ///   - count: The number of shares in the response
    ///   - offset: The offset for pagination
    ///   - filter: The device share status filter for the results
    /// - Returns: A `Promise<Page<DeviceShare>>`
    open class func getShares(uid: String, count: Int, offset: Int = 0, filter: DeviceShareFilter = .all) -> Promise<Page<DeviceShare>> {
        let promise = Promise<Page<DeviceShare>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/shares"
        let parameters: [String:Any] = [
            "count": count,
            "offset": offset,
            "filter": filter.rawValue
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            do {
                let page = try paginatedDeviceSharesToInstance(response)
                promise.fulfill(page)
            } catch {
                promise.reject(error)
            }
         }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get all of a user's Device Shares using recursive requests
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - uid: The user's id
    ///   - filter: The device share status filter for the results
    /// - Returns: A `Promise<Page<DeviceShare>>`
    open class func getShares(uid: String, filter: DeviceShareFilter = .all) -> Promise<Page<DeviceShare>> {
        return getSharesRecursive(Page<DeviceShare>(), uid: uid, filter: filter)
    }
    
    /// Get a Device's Share
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - sid: The Device Share's id
    /// - Returns: A `Promise<DeviceShare>`
    open class func getShare(id: String, sid: String) -> Promise<DeviceShare> {
        let promise = Promise<DeviceShare>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/shares/\(sid)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let share = DeviceShare(JSON: data) {
                promise.fulfill(share)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Share a Device with someone by sending an invitation to the recipient's email.
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - email: The recipient's email
    /// - Returns: A `Promise<DeviceShare>`
    open class func share(id: String, email: String) -> Promise<DeviceShare> {
        let promise = Promise<DeviceShare>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/shares"
        
        if isValidEmail(email: email) {
            let parameters = [
                "email": email
            ]
            
            APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
                if let data = response["data"] as? [String:Any], let sid = data["id"] as? String {
                    self.getShare(id: id, sid: sid).then { share -> Void in
                        promise.fulfill(share)
                    }.catch { error -> Void in
                        promise.reject(error)
                    }
                } else {
                    promise.reject(ArtikError.json(reason: .unexpectedFormat))
                }
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noEmailOrInvalid))
        }
        return promise.promise
    }
    
    
    /// Revoke a Device Share
    ///
    /// - Parameters:
    ///   - id: The Device's id
    ///   - sid: The Device Share's id
    /// - Returns: A `Promise<Void>`
    open class func unshare(id: String, sid: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/\(id)/shares/\(sid)"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).then { _ -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: Secure Device Registration
    
    /// Update the registration request issued earlier by associating it with an authenticated user and capture all additional information required to add a new device.
    ///
    /// - Parameters:
    ///   - did: The Device's ID.
    ///   - pin: The PIN obtained in the registration call.
    /// - Returns: Returns a `Promise<String>` containing the request ID.
    open class func confirmUser(did: String, pin: String) -> Promise<String> {
        let promise = Promise<String>.pending()
        let path = ArtikCloudSwiftSettings.securePath + "/devices/registrations/pin"
        let parameters = [
            "deviceId": did,
            "pin": pin
        ]
        
        APIHelpers.makeRequest(url: path, method: .put, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let rid = data["rid"] as? String {
                promise.fulfill(rid)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Clears any associations from the secure device registration and returns the targeted device.
    ///
    /// - Parameter did: The Device's ID.
    /// - Returns: A `Promise<Device>`.
    open class func unregister(did: String) -> Promise<Device> {
        let promise = Promise<Device>.pending()
        let path = ArtikCloudSwiftSettings.securePath + "/devices/\(did)/registrations"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: ["deviceId": did], encoding: URLEncoding.queryString).then { response -> Void in
            if let data = response["data"] as? [String:Any], let device = Device(JSON: data) {
                promise.fulfill(device)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Private Methods
    
    fileprivate class func getRecursive(_ container: Page<Device>, uid: String, offset: Int = 0, includeProperties: Bool? = nil, owner: DeviceOwner? = nil, includeShareInfo: Bool? = nil, includeDeviceTypeInfo: Bool? = nil) -> Promise<Page<Device>> {
        let promise = Promise<Page<Device>>.pending()
        
        DevicesAPI.get(uid: uid, count: 100, offset: offset, includeProperties: includeProperties, owner: owner, includeShareInfo: includeShareInfo, includeDeviceTypeInfo: includeDeviceTypeInfo).then { result -> Void in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getRecursive(container, uid: uid, offset: Int(result.offset) + result.data.count, includeProperties: includeProperties, owner: owner, includeShareInfo: includeShareInfo, includeDeviceTypeInfo: includeDeviceTypeInfo).then { result -> Void in
                    promise.fulfill(result)
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.fulfill(container)
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    private class func getStatusesRecursive(_ container: Page<DeviceStatus>, ids: [String], parameters: [String:Any]? = nil) -> Promise<Page<DeviceStatus>> {
        let promise = Promise<Page<DeviceStatus>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devices/status"
        let maxIdsCount = 100
        var currentIds = ids
        var nextIds: [String]?
        
        if ids.count > 0 {
            if ids.count > maxIdsCount {
                currentIds = Array(ids[0..<maxIdsCount])
                nextIds = Array(ids[maxIdsCount..<ids.count])
            }
            var dids = currentIds[0]
            for i in 1..<currentIds.count {
                dids += ",\(currentIds[i])"
            }
            var finalParams = (parameters ?? [String:Any]())
            finalParams["dids"] = dids
            
            APIHelpers.makeRequest(url: path, method: .get, parameters: finalParams, encoding: URLEncoding.queryString).then { response -> Void in
                if let total = response["total"] as? Int64, let count = response["count"] as? Int64, let data = response["data"] as? [[String:Any]] {
                    if data.count != Int(count) {
                        promise.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                        return
                    }
                    container.total += total
                    
                    for item in data {
                        if let status = DeviceStatus(JSON: item) {
                            container.data.append(status)
                        } else {
                            promise.reject(ArtikError.json(reason: .invalidItem))
                            return
                        }
                    }
                    
                    if let nextIds = nextIds {
                        getStatusesRecursive(container, ids: nextIds, parameters: parameters).then { final -> Void in
                            promise.fulfill(final)
                        }.catch { error -> Void in
                            promise.reject(error)
                        }
                    } else {
                        promise.fulfill(container)
                    }
                } else {
                    promise.reject(ArtikError.json(reason: .unexpectedFormat))
                }
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.fulfill(container)
        }
        return promise.promise
    }
    
    private class func getSharesRecursive(_ container: Page<DeviceShare>, id: String, offset: Int = 0) -> Promise<Page<DeviceShare>> {
        let promise = Promise<Page<DeviceShare>>.pending()
        
        self.getShares(id: id, count: 100, offset: offset).then { result -> Void in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            container.offset = result.offset
            
            if container.total > Int64(container.data.count) {
                self.getSharesRecursive(container, id: id, offset: Int(result.offset) + result.data.count).then { result -> Void in
                    promise.fulfill(result)
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.fulfill(container)
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    private class func getSharesRecursive(_ container: Page<DeviceShare>, uid: String, offset: Int = 0, filter: DeviceShareFilter = .all) -> Promise<Page<DeviceShare>> {
        let promise = Promise<Page<DeviceShare>>.pending()
        
        self.getShares(uid: uid, count: 100, offset: offset, filter: filter).then { result -> Void in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            container.offset = result.offset
            
            if container.total > Int64(container.data.count) {
                self.getSharesRecursive(container, uid: uid, offset: Int(result.offset) + result.data.count, filter: filter).then { result -> Void in
                    promise.fulfill(result)
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.fulfill(container)
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    fileprivate class func paginatedDeviceSharesToInstance(_ response: [String:Any]) throws -> Page<DeviceShare> {
        if let offset = response["offset"] as? Int64, let total = response["total"] as? Int64, let count = response["count"] as? Int64, let data = response["data"] as? [String:Any], let shares = data["shares"] as? [Any] {
            let page = Page<DeviceShare>(offset: offset, total: total)
            if shares.count != Int(count) {
                throw ArtikError.json(reason: .countAndContentDoNotMatch)
            }
            for item in shares {
                if let item = item as? [String:Any], let share = DeviceShare(JSON: item) {
                    page.data.append(share)
                } else {
                    throw ArtikError.json(reason: .invalidItem)
                }
            }
            return page
        }
        throw ArtikError.json(reason: .unexpectedFormat)
    }
    
    fileprivate class func isValidEmail(email: String) -> Bool {
        let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}")
        return emailTest.evaluate(with: email)
    }
}
