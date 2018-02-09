//
//  DeviceTypesAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/8/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

open class DeviceTypesAPI {
    
    // MARK: - Main Methods
    
    /// Get a Device Type
    ///
    /// - Parameter id: The Device Type's id
    /// - Returns: A `Promise<DeviceType>`
    open class func get(id: String) -> Promise<DeviceType> {
        let promise = Promise<DeviceType>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let type = DeviceType(JSON: data) {
                promise.fulfill(type)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get Device Types using pagination
    ///
    /// - Parameters:
    ///   - count: The count of results, max 100.
    ///   - offset: The offset for pagination
    ///   - name: (Optional) Filter results using a name query
    ///   - queryUniqueNameAlso: Query also the types' unique names, default: false
    ///   - initializableTypesOnly: Return only types which can be onboarded by the User/Application, default: false
    ///   - cloudConnectorTypesOnly: Return only types which are cloud connectors, default: false
    /// - Returns: A `Promise<Page<DeviceType>>`
    open class func get(count: Int, offset: Int = 0, name: String? = nil, queryUniqueNameAlso: Bool = false, initializableTypesOnly: Bool = false, cloudConnectorTypesOnly: Bool = false) -> Promise<Page<DeviceType>> {
        let promise = Promise<Page<DeviceType>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + (cloudConnectorTypesOnly ? "/devicetypes/cloudconnectors" : "/devicetypes")
        var parameters: [String:Any] = [
            "count": count,
            "offset": offset
        ]
        
        if let name = name {
            if queryUniqueNameAlso {
                parameters["name"] = name
            } else {
                parameters["nameSearch"] = name
            }
        }
        if initializableTypesOnly {
            parameters["createDevice"] = true
        }
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let offset = response["offset"] as? Int64, let total = response["total"] as? Int64, let count = response["count"] as? Int64, let types = (response["data"] as? [String:Any])?["deviceTypes"] as? [[String:Any]] {
                let page = Page<DeviceType>(offset: offset, total: total)
                if types.count != Int(count) {
                    promise.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in types {
                    if let type = DeviceType(JSON: item) {
                        page.data.append(type)
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
    
    /// Get Device Types owned by a `User`
    ///
    /// - Parameters:
    ///   - uid: the `User`'s id
    ///   - count: The count of results, max 100
    ///   - offset: The offset for pagination
    ///   - name: (Optional) Filter results using a name query
    ///   - includeOrganization: Include `User`'s organization's Device Types in response, default: false
    /// - Returns: Promise<Page<DeviceType>>
    open class func get(uid: String, count: Int, offset: Int = 0, name: String? = nil, includeOrganization: Bool = false) -> Promise<Page<DeviceType>> {
        let promise = Promise<Page<DeviceType>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/devicetypes"
        var parameters: [String:Any] = [
            "count": count,
            "offset": offset
        ]
        if includeOrganization {
            parameters["includeOrganization"] = true
        }
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let types = (response["data"] as? [String:Any])?["deviceTypes"] as? [[String:Any]] {
                let page = Page<DeviceType>(offset: offset, total: total)
                if types.count != Int(count) {
                    promise.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in types {
                    if let type = DeviceType(JSON: item) {
                        page.data.append(type)
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
    
    // MARK: - Manifest Properties
    
    /// Get the Manifest Properties of a Device Type
    ///
    /// - Parameters:
    ///   - id: The Device Type's id
    ///   - version: (Optional) The Manifest's version number, if ommited the latest is returned
    /// - Returns: A `Promise<ManifestProperties>`
    open class func getManifestProperties(id: String, version: Int64? = nil) -> Promise<ManifestProperties> {
        let promise = Promise<ManifestProperties>.pending()
        var path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(id)/manifests"
        if let version = version {
            path += "/\(version)/properties"
        } else {
            path += "/latest/properties"
        }
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let manifest = ManifestProperties(JSON: data) {
                promise.fulfill(manifest)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get all available Manifest versions of a Device Type
    ///
    /// - Parameter id: The Device Type/Manifest id
    /// - Returns: A `Promise<[Int64]>`
    open class func getManifestVersions(id: String) -> Promise<[Int64]> {
        let promise = Promise<[Int64]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(id)/availablemanifestversions"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let versions = (response["data"] as? [String:Any])?["versions"] as? [Int64] {
                promise.fulfill(versions)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Uploads an Approved List as a CSV file.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - list: An array of vdids to preapprove.
    /// - Returns: A `Promise<String>`.
    open class func uploadApprovedList(dtid: String, list: [String]) -> Promise<String> {
        let promise = Promise<String>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist"
        
        guard let data = list.joined(separator: "\n").data(using: .utf8) else {
            promise.reject(ArtikError.deviceType(reason: .approvedListFailedToEncode))
            return promise.promise
        }
        
        APIHelpers.uploadData(data, to: path, method: .post).then { response -> Void in
            if let id = response["uploadId"] as? String {
                promise.fulfill(id)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get a summary of the status of an uploaded CSV file.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - uploadId: The CSV file's upload ID.
    /// - Returns: A `Promise<ApprovedListUploadSummary>`.
    open class func checkApprovedListUpload(dtid: String, uploadId: String) -> Promise<ApprovedListUploadSummary> {
        let promise = Promise<ApprovedListUploadSummary>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist/\(uploadId)/status"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let summary = ApprovedListUploadSummary(JSON: data) {
                promise.fulfill(summary)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get the rows that were rejected in an uploaded CSV using pagination.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - uploadId: The CSV file's upload ID.
    ///   - count: The count used for pagination, max `100`.
    ///   - offset: The offset used for pagination, default `0`.
    /// - Returns: A `Promise<Page<ApprovedListRejectedRow>>`.
    open class func getApprovedListRejectedRows(dtid: String, uploadId: String, count: Int, offset: Int = 0) -> Promise<Page<ApprovedListRejectedRow>> {
        let promise = Promise<Page<ApprovedListRejectedRow>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist/\(uploadId)/rejectedRows"
        let parameters: [String:Any] = [
            "count": count,
            "offset": offset
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let rows = response["data"] as? [[String:Any]] {
                let page = Page<ApprovedListRejectedRow>(offset: offset, total: total)
                guard rows.count == Int(count) else {
                    promise.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                
                for item in rows {
                    if let row = ApprovedListRejectedRow(JSON: item) {
                        page.data.append(row)
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
    
    /// Get the rows that were rejected in an uploaded CSV using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - uploadId: The CSV file's upload ID.
    /// - Returns: A `Promise<Page<ApprovedListRejectedRow>>`.
    open class func getApprovedListRejectedRows(dtid: String, uploadId: String) -> Promise<Page<ApprovedListRejectedRow>> {
        return getApprovedListRejectedRowsRecursive(Page<ApprovedListRejectedRow>(), dtid: dtid, uploadId: uploadId)
    }
    
    /// Get the Approved List of a Device Type using pagination.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - count: The count used for pagination, max `100`.
    ///   - offset: The offset used for pagination, default `0`.
    /// - Returns: A `Promise<Page<String>>`.
    open class func getApprovedList(dtid: String, count: Int, offset: Int = 0) -> Promise<Page<String>> {
        let promise = Promise<Page<String>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist"
        let parameters: [String:Any] = [
            "count": count,
            "offset": offset
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let data = response["data"] as? [[String:Any]] {
                let page = Page<String>(offset: offset, total: total)
                guard data.count == Int(count) else {
                    promise.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                
                for item in data {
                    if let vdid = item["vdid"] as? String {
                        page.data.append(vdid)
                    } else {
                        promise.reject(ArtikError.json(reason: .invalidItem))
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
    
    /// Get the Approved List of a Device Type using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    /// - Returns: A `Promise<Page<String>>`.
    open class func getApprovedList(dtid: String) -> Promise<Page<String>> {
        return getApprovedListRecursive(Page<String>(), dtid: dtid)
    }
    
    /// Removes a specified device from the device type's Approved List.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - vdid: The Vendor Device ID.
    /// - Returns: A `Promise<Void>`.
    open class func removeFromApprovedList(dtid: String, vdid: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist/\(vdid)"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).then { _ -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Enables or disables a device type's Approved List.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - enabled: The desired state of use of the Approved List.
    /// - Returns: A `Promise<Void>`.
    open class func toggleApprovedList(dtid: String, enabled: Bool) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist/enable"
        let parameters: [String:Any] = [
            "enableWhitelist": enabled
        ]
        
        APIHelpers.makeRequest(url: path, method: .put, parameters: parameters, encoding: JSONEncoding.default).then { _ -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get the enabled/disabled status of an Approved List.
    ///
    /// - Parameter dtid: The Device Type's ID.
    /// - Returns: A `Promise<Bool>`.
    open class func isApprovedListEnabled(dtid: String) -> Promise<Bool> {
        let promise = Promise<Bool>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist/status"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let enabled = data["enableWhitelist"] as? Bool {
                promise.fulfill(enabled)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Uploads a Public X.509 certificate for a device type.
    ///
    /// - Parameters:
    ///   - dtid: the Device Type's ID.
    ///   - certificate: The certificate as a `String`.
    /// - Returns: A `Promise<[ApprovedListCertificate]>`.
    open class func uploadApprovedListCertificate(dtid: String, certificate: String) -> Promise<[ApprovedListCertificate]> {
        let promise = Promise<[ApprovedListCertificate]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist/certificates"
        let parameters: [String:Any] = [
            "certificate": certificate
        ]
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
            if let data = response["data"] as? [[String:Any]] {
                var results = [ApprovedListCertificate]()
                for item in data {
                    if let certificate = ApprovedListCertificate(JSON: item) {
                        results.append(certificate)
                    } else {
                        promise.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                promise.fulfill(results)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Deletes an Approved List certificate for a device type.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - certificateId: The certificate's ID.
    /// - Returns: A `Promise<Void>`.
    open class func removeApprovedListCertificate(dtid: String, certificateId: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist/certificates/\(certificateId)"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).then { _ -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get details of an Approved List's certificates.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    /// - Returns: A `Promise<[ApprovedListCertificate]>`.
    open class func getApprovedListCertificates(dtid: String) -> Promise<[ApprovedListCertificate]> {
        let promise = Promise<[ApprovedListCertificate]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + ""
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [[String:Any]] {
                var results = [ApprovedListCertificate]()
                for item in data {
                    if let certificate = ApprovedListCertificate(JSON: item) {
                        results.append(certificate)
                    } else {
                        promise.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                promise.fulfill(results)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get the id of a device instance corresponding to an approved vendor id.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's ID.
    ///   - vdid: The Vendor Device ID to seek.
    /// - Returns: A `Promise<String>` fulfilling with the `did`.
    open class func findApprovedListDevice(dtid: String, vdid: String) -> Promise<String> {
        let promise = Promise<String>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicetypes/\(dtid)/whitelist/vdid/\(vdid)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let did = data["did"] as? String {
                promise.fulfill(did)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Private Methods
    
    fileprivate class func getApprovedListRejectedRowsRecursive(_ container: Page<ApprovedListRejectedRow>, dtid: String, uploadId: String, offset: Int = 0) -> Promise<Page<ApprovedListRejectedRow>> {
        let promise = Promise<Page<ApprovedListRejectedRow>>.pending()
        
        getApprovedListRejectedRows(dtid: dtid, uploadId: uploadId, count: 100, offset: offset).then { result -> Void in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getApprovedListRejectedRowsRecursive(container, dtid: dtid, uploadId: uploadId, offset: Int(result.offset) + result.data.count).then { result -> Void in
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
    
    fileprivate class func getApprovedListRecursive(_ container: Page<String>, dtid: String, offset: Int = 0) -> Promise<Page<String>> {
        let promise = Promise<Page<String>>.pending()
        
        getApprovedList(dtid: dtid, count: 100, offset: offset).then { result -> Void in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getApprovedListRecursive(container, dtid: dtid, offset: Int(result.offset) + result.data.count).then { result -> Void in
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
}
