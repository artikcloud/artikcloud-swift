//
//  DeviceManagementAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 1/12/18.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

open class DeviceManagementAPI {
    
    // MARK: - Main Methods
    
    /// Writes Server Properties for a device.
    ///
    /// - Parameters:
    ///   - did: The Device's ID.
    ///   - properties: The properties to write for the device.
    /// - Returns: A `Promise<Void>`.
    open class func writeServerProperties(did: String, properties: [String:Any]) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/devices/\(did)/serverproperties"
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: properties, encoding: JSONEncoding.default).done { _ in
            resolver.fulfill(())
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Deletes all Server Properties associated with the device.
    ///
    /// - Parameter did: The Device's ID.
    /// - Returns: A `Promise<Void>`.
    open class func deleteServerProperties(did: String) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/devices/\(did)/serverproperties"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).done { _ in
            resolver.fulfill(())
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Read the properties for a device.
    ///
    /// - Parameters:
    ///   - did: The Device's ID.
    ///   - includeTimestamp: (Optional) Whether to include last-updated timestamp for Device and Server Properties. Defaults to false.
    /// - Returns: A `Promise<DeviceManagementProperties>`.
    open class func readProperties(did: String, includeTimestamp: Bool = false) -> Promise<DeviceManagementProperties> {
        let (promise, resolver) = Promise<DeviceManagementProperties>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/devices/\(did)/properties"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let properties = DeviceManagementProperties(JSON: data) {
                resolver.fulfill(properties)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Queries and returns properties across devices using pagination.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type ID of the devices.
    ///   - count: Count used for pagination.
    ///   - offset: (Optional) Offset used for pagination. Defaults to 0.
    ///   - filter: (Optional) An Array of "key=value" pairs used to filter results. Nested JSON objects are separated with dot notation.
    /// - Returns: A `Promise<Page<DeviceManagementProperties>>`.
    open class func readProperties(dtid: String, count: Int, offset: Int = 0, filter: [String]? = nil) -> Promise<Page<DeviceManagementProperties>> {
        let (promise, resolver) = Promise<Page<DeviceManagementProperties>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/devices/properties"
        let parameters = APIHelpers.removeNilParameters([
            "dtid": dtid,
            "count": count,
            "offset": offset,
            "filter": filter?.joined(separator: ",")
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let data = response["data"] as? [String:Any], let total = data["total"] as? Int64, let offset = data["offset"] as? Int64, let count = data["count"] as? Int64, let propertiesRaw = data["properties"] as? [[String:Any]] {
                let page = Page<DeviceManagementProperties>(offset: offset, total: total)
                guard propertiesRaw.count == Int(count) else {
                    resolver.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in propertiesRaw {
                    if let property = DeviceManagementProperties(JSON: item) {
                        page.data.append(property)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
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
    
    /// Queries and returns properties across devices using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type ID of the devices.
    ///   - filter: (Optional) An Array of "key=value" pairs used to filter results. Nested JSON objects are separated with dot notation.
    /// - Returns: A `Promise<Page<DeviceManagementProperties>>`.
    open class func readProperties(dtid: String, filter: [String]? = nil) -> Promise<Page<DeviceManagementProperties>> {
        return readPropertiesRecursive(Page<DeviceManagementProperties>(), dtid: dtid, filter: filter)
    }
    
    /// Returns the device management configuration of a device type.
    ///
    /// - Parameter dtid: The Device Type ID.
    /// - Returns: A `Promise<DeviceTypeConfiguration>`
    open class func getDeviceTypeConfiguration(dtid: String) -> Promise<DeviceTypeConfiguration> {
        let (promise, resolver) = Promise<DeviceTypeConfiguration>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/devicetypes/\(dtid)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let configuration = DeviceTypeConfiguration(JSON: data) {
                resolver.fulfill(configuration)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Modifies the device management configuration of a device type.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type ID.
    ///   - devicePropertiesEnabled: (Optional) Indicates whether Device Properties are enabled for the device type. Defaults to false.
    ///   - pmin: (Optional) Minimum time in seconds the LWM2M client must wait between notifications. Defaults to 300 (5 minutes). Min 60 (1 minute), max 3600 (1 hour).
    ///   - pmax: (Optional) Maximum time in seconds the LWM2M client may wait between notifications. Must not be smaller than pmin. Defaults to 21600 (6 hours). Min 3600 (1 hour), max 86400 (24 hours).
    ///   - taskExpiresAfter: (Optional) Custom expiration time in seconds for the device type's tasks. If not specified, default expiration time is 7 days. Min 60 (1 minute), max 604800 (7 days).
    /// - Returns: A `Promise<DeviceTypeConfiguration>`.
    open class func setDeviceTypeConfiguration(dtid: String, devicePropertiesEnabled: Bool? = nil, pmin: Int64? = nil, pmax: Int64? = nil, taskExpiresAfter: Int64? = nil) -> Promise<DeviceTypeConfiguration> {
        let (promise, resolver) = Promise<DeviceTypeConfiguration>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/devicetypes/\(dtid)"
        var parameters = [String:Any]()
        if let devicePropertiesEnabled = devicePropertiesEnabled {
            parameters["devicePropertiesEnabled"] = devicePropertiesEnabled
        }
        if let pmin = pmin {
            guard pmin >= 60, pmin <= 3600 else {
                resolver.reject(ArtikError.deviceManagement(reason: .invalidPmin))
                return promise
            }
            parameters["pmin"] = pmin
        }
        if let pmax = pmax {
            guard pmax >= 3600, pmax <= 86400 else {
                resolver.reject(ArtikError.deviceManagement(reason: .invalidPmax))
                return promise
            }
            parameters["pmax"] = pmax
        }
        if let taskExpiresAfter = taskExpiresAfter {
            guard taskExpiresAfter >= 60, taskExpiresAfter <= 604800 else {
                resolver.reject(ArtikError.deviceManagement(reason: .invalidTaskExpiresAfter))
                return promise
            }
            parameters["taskExpiresAfter"] = taskExpiresAfter
        }
        guard parameters.count > 0 else {
            getDeviceTypeConfiguration(dtid: dtid).done { result in
                resolver.fulfill(result)
            }.catch { error -> Void in
                resolver.reject(error)
            }
            return promise
        }
        
        APIHelpers.makeRequest(url: path, method: .put, parameters: parameters, encoding: JSONEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let configuration = DeviceTypeConfiguration(JSON: data) {
                resolver.fulfill(configuration)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Creates a new task for one or more devices of a single device type.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type ID to operate on.
    ///   - filter: (Optional) An Array of "key=value" pairs used to filter results. Nested JSON objects are separated with dot notation.
    ///   - type: Operation to perform (Read, Write, or Execute).
    ///   - property: Property to operate on, using dot notation.
    ///   - parameters: (Optional) JSON object containing additional parameters for the task.
    /// - Returns: A `Promise<DeviceManagementTask>`.
    open class func createTask(dtid: String, filter: [String]? = nil, type: DeviceManagementTask.TaskType, property: String, parameters: [String:Any]? = nil) -> Promise<DeviceManagementTask> {
        return createTask(dtid: dtid, dids: nil, filter: filter, type: type, property: property, parameters: parameters)
    }
    
    /// Creates a new task for one or more devices of a single device type.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type ID to operate on.
    ///   - dids: An Array of device IDs to operate on.
    ///   - type: Operation to perform (Read, Write, or Execute).
    ///   - property: Property to operate on, using dot notation.
    ///   - parameters: (Optional) JSON object containing additional parameters for the task.
    /// - Returns: A `Promise<DeviceManagementTask>`.
    open class func createTask(dtid: String, dids: [String], type: DeviceManagementTask.TaskType, property: String, parameters: [String:Any]? = nil) -> Promise<DeviceManagementTask> {
        return createTask(dtid: dtid, dids: dids, filter: nil, type: type, property: property, parameters: parameters)
    }
    
    /// Returns a Task.
    ///
    /// - Parameter id: The Task's ID.
    /// - Returns: A `Promise<DeviceManagementTask>`.
    open class func getTask(id: String) -> Promise<DeviceManagementTask> {
        let (promise, resolver) = Promise<DeviceManagementTask>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/tasks/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let task = DeviceManagementTask(JSON: data) {
                resolver.fulfill(task)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Returns all tasks for a device type using pagination.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type ID.
    ///   - count: The count used for pagination.
    ///   - offset: (Optional) The offset used for pagination. Default to `0`.
    ///   - status: (Optional) The tasks' status.
    /// - Returns: A `Promise<DeviceManagementTaskPage>`.
    open class func getTasks(dtid: String, count: Int, offset: Int = 0, status: DeviceManagementTask.TaskStatus? = nil) -> Promise<DeviceManagementTaskPage> {
        let (promise, resolver) = Promise<DeviceManagementTaskPage>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/tasks"
        let parameters = APIHelpers.removeNilParameters([
            "dtid": dtid,
            "count": count,
            "offset": offset,
            "status": status?.rawValue
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let total = response["total"] as? Int64,
                let offset = response["offset"] as? Int64,
                let count = response["count"] as? Int64,
                let tasks = (response["data"] as? [String:Any])?["tasks"] as? [[String:Any]],
                let statusCounts = response["statusCounts"] as? [String:Int64],
                let scheduled = statusCounts["SCHEDULED"],
                let requested = statusCounts["REQUESTED"],
                let queuing = statusCounts["QUEUING"],
                let processing = statusCounts["PROCESSING"],
                let complete = statusCounts["COMPLETE"],
                let cancelled = statusCounts["CANCELLED"] {
                let page = DeviceManagementTaskPage(offset: offset, total: total, scheduled: scheduled, requested: requested, queuing: queuing, processing: processing, complete: complete, cancelled: cancelled)
                guard tasks.count == Int(count) else {
                    resolver.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in tasks {
                    if let task = DeviceManagementTask(JSON: item) {
                        page.data.append(task)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
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
    
    /// Returns all tasks for a device type using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type ID.
    ///   - status: (Optional) The tasks' status.
    /// - Returns: A `Promise<DeviceManagementTaskPage>`.
    open class func getTasks(dtid: String, status: DeviceManagementTask.TaskStatus? = nil) -> Promise<DeviceManagementTaskPage> {
        return getTasksRecursive(DeviceManagementTaskPage(), dtid: dtid, status: status)
    }
    
    /// Returns tasks for a device ID using pagination.
    ///
    /// - Parameters:
    ///   - did: The Device's ID.
    ///   - count: The count used for pagination.
    ///   - offset: (Optional) The offset used for pagination. Defaults to `0`.
    ///   - status: (Optional) The device tasks' status.
    /// - Returns: A `Promise<Page<DeviceManagementTask>>`.
    open class func getTasks(did: String, count: Int, offset: Int = 0, status: DeviceManagementDeviceTaskState.TaskStatus? = nil) -> Promise<Page<DeviceManagementTask>> {
        let (promise, resolver) = Promise<Page<DeviceManagementTask>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/devices/\(did)/tasks"
        let parameters = APIHelpers.removeNilParameters([
            "count": count,
            "offset": offset,
            "status": status?.rawValue
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let tasks = (response["data"] as? [String:Any])?["tasks"] as? [[String:Any]] {
                let page = Page<DeviceManagementTask>(offset: offset, total: total)
                guard tasks.count == Int(count) else {
                    resolver.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in tasks {
                    if let task = DeviceManagementTask(JSON: item) {
                        page.data.append(task)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
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
    
    /// Returns tasks for a device ID using recursive requests.
    ///
    /// - Parameters:
    ///   - did: The Device's ID.
    ///   - status: (Optional) The device tasks' status.
    /// - Returns: A `Promise<Page<DeviceManagementTask>>`.
    open class func getTasks(did: String, status: DeviceManagementDeviceTaskState.TaskStatus? = nil) -> Promise<Page<DeviceManagementTask>> {
        return getTasksRecursive(Page<DeviceManagementTask>(), did: did, status: status)
    }
    
    /// Returns individual device task statuses using pagination.
    ///
    /// - Parameters:
    ///   - id: The Task's ID.
    ///   - count: The count used for pagination.
    ///   - offset: (Optional) The offset used for pagination. Defaults to `0`.
    ///   - dids: (Optional) List of device IDs used to filter results.
    ///   - status: (Optional) Task status used to filter results.
    /// - Returns: A `Promise<Page<DeviceManagementDeviceTaskState>>`.
    open class func getDeviceTaskStatuses(id: String, count: Int, offset: Int = 0, dids: [String]? = nil, status: DeviceManagementDeviceTaskState.TaskStatus? = nil) -> Promise<Page<DeviceManagementDeviceTaskState>> {
        let (promise, resolver) = Promise<Page<DeviceManagementDeviceTaskState>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/tasks/\(id)/statuses"
        let parameters = APIHelpers.removeNilParameters([
            "count": count,
            "offset": offset,
            "dids": dids?.joined(separator: ","),
            "status": status?.rawValue
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let tasks = (response["data"] as? [String:Any])?["statuses"] as? [[String:Any]] {
                let page = Page<DeviceManagementDeviceTaskState>(offset: offset, total: total)
                guard tasks.count == Int(count) else {
                    resolver.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in tasks {
                    if let task = DeviceManagementDeviceTaskState(JSON: item) {
                        page.data.append(task)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
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
    
    /// Returns individual device task statuses using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - id: The Task's ID.
    ///   - dids: (Optional) List of device IDs used to filter results.
    ///   - status: (Optional) Task status used to filter results.
    /// - Returns: A `Promise<Page<DeviceManagementDeviceTaskState>>`.
    open class func getDeviceTaskStatuses(id: String, dids: [String]? = nil, status: DeviceManagementDeviceTaskState.TaskStatus? = nil) -> Promise<Page<DeviceManagementDeviceTaskState>> {
        return getDeviceTaskStatusesRecursive(Page<DeviceManagementDeviceTaskState>(), id: id, dids: dids, status: status)
    }
    
    /// Returns the history of status changes for a task.
    ///
    /// - Parameter id: The Task's ID.
    /// - Returns: A `Promise<[DeviceManagementTask.TaskState]>`.
    open class func getTaskStatusHistory(id: String) -> Promise<[DeviceManagementTask.TaskState]> {
        let (promise, resolver) = Promise<[DeviceManagementTask.TaskState]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/tasks/\(id)/statuses/history"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.queryString).done { response in
            if let data = response["data"] as? [String:Any], let history = data["history"] as? [[String:Any]] {
                var result = [DeviceManagementTask.TaskState]()
                for item in history {
                    if let ddt = DeviceManagementTask.TaskState(JSON: item) {
                        result.append(ddt)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
                    }
                }
                resolver.fulfill(result)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Returns the history of status changes for a specific device ID in a task.
    ///
    /// - Parameters:
    ///   - id: The Task's ID.
    ///   - did: The Device's ID.
    /// - Returns: A `Promise<[DeviceManagementDeviceTaskState]>`.
    open class func getDeviceTaskStatusHistory(id: String, did: String) -> Promise<[DeviceManagementDeviceTaskState]> {
        let (promise, resolver) = Promise<[DeviceManagementDeviceTaskState]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/tasks/\(id)/statuses/history"
        let parameters = [
            "did": did
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let data = response["data"] as? [String:Any], let history = data["history"] as? [[String:Any]] {
                var result = [DeviceManagementDeviceTaskState]()
                for item in history {
                    if let ddt = DeviceManagementDeviceTaskState(JSON: item) {
                        result.append(ddt)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
                    }
                }
                resolver.fulfill(result)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Cancels a task. Only affects devices that have not completed the task.
    ///
    /// - Parameter id: The Task's ID.
    /// - Returns: A `Promise<DeviceManagementTask>`.
    open class func cancelTask(id: String) -> Promise<DeviceManagementTask> {
        let (promise, resolver) = Promise<DeviceManagementTask>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/tasks/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .put, parameters: ["status": DeviceManagementTask.TaskStatus.cancelled.rawValue], encoding: JSONEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let task = DeviceManagementTask(JSON: data) {
                resolver.fulfill(task)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Cancels a single device in a task. Only affects devices that have not completed the task.
    ///
    /// - Parameters:
    ///   - id: The Task's ID.
    ///   - did: The Device's ID.
    /// - Returns: A `Promise<DeviceManagementDeviceTaskState>`.
    open class func cancelDeviceTask(id: String, did: String) -> Promise<DeviceManagementDeviceTaskState> {
        let (promise, resolver) = Promise<DeviceManagementDeviceTaskState>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/tasks/\(id)/devices/\(did)"
        
        APIHelpers.makeRequest(url: path, method: .put, parameters: ["status": DeviceManagementDeviceTaskState.TaskStatus.cancelled.rawValue], encoding: JSONEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let task = DeviceManagementDeviceTaskState(JSON: data) {
                resolver.fulfill(task)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Helper Methods
    
    fileprivate class func readPropertiesRecursive(_ container: Page<DeviceManagementProperties>, dtid: String, offset: Int = 0, filter: [String]? = nil) -> Promise<Page<DeviceManagementProperties>> {
        let (promise, resolver) = Promise<Page<DeviceManagementProperties>>.pending()
        
        readProperties(dtid: dtid, count: 100, offset: offset, filter: filter).done { result in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.readPropertiesRecursive(container, dtid: dtid, offset: Int(result.offset) + result.data.count, filter: filter).done { result in
                    resolver.fulfill(result)
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
    
    fileprivate class func createTask(dtid: String, dids: [String]?, filter: [String]?, type: DeviceManagementTask.TaskType, property: String, parameters params: [String:Any]?) -> Promise<DeviceManagementTask> {
        let (promise, resolver) = Promise<DeviceManagementTask>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/devicemgmt/tasks"
        let parameters = APIHelpers.removeNilParameters([
            "dtid": dtid,
            "dids": dids,
            "filter": filter?.joined(separator: ","),
            "taskType": type.rawValue,
            "taskParameters": params
        ])
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let task = DeviceManagementTask(JSON: data) {
                resolver.fulfill(task)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    fileprivate class func getTasksRecursive(_ container: DeviceManagementTaskPage, dtid: String, offset: Int = 0, status: DeviceManagementTask.TaskStatus? = nil) -> Promise<DeviceManagementTaskPage> {
        let (promise, resolver) = Promise<DeviceManagementTaskPage>.pending()
        
        getTasks(dtid: dtid, count: 100, offset: offset, status: status).done { result in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            container.scheduled = result.scheduled
            container.requested = result.requested
            container.queuing = result.queuing
            container.processing = result.processing
            container.complete = result.complete
            container.cancelled = result.cancelled
            
            if container.total > Int64(container.data.count) {
                self.getTasksRecursive(container, dtid: dtid, offset: Int(result.offset) + result.data.count, status: status).done { result in
                    resolver.fulfill(result)
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
    
    fileprivate class func getDeviceTaskStatusesRecursive(_ container: Page<DeviceManagementDeviceTaskState>, id: String, offset: Int = 0, dids: [String]? = nil, status: DeviceManagementDeviceTaskState.TaskStatus? = nil) -> Promise<Page<DeviceManagementDeviceTaskState>> {
        let (promise, resolver) = Promise<Page<DeviceManagementDeviceTaskState>>.pending()
        
        getDeviceTaskStatuses(id: id, count: 100, offset: offset, dids: dids, status: status).done { result in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getDeviceTaskStatusesRecursive(container, id: id, offset: Int(result.offset) + result.data.count, dids: dids, status: status).done { result in
                    resolver.fulfill(result)
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
    
    fileprivate class func getTasksRecursive(_ container: Page<DeviceManagementTask>, did: String, offset: Int = 0, status: DeviceManagementDeviceTaskState.TaskStatus? = nil) -> Promise<Page<DeviceManagementTask>> {
        let (promise, resolver) = Promise<Page<DeviceManagementTask>>.pending()
        
        getTasks(did: did, count: 100, offset: offset, status: status).done { result in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getTasksRecursive(container, did: did, offset: Int(result.offset) + result.data.count, status: status).done { result in
                    resolver.fulfill(result)
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
