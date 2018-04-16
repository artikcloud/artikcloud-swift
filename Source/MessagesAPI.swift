//
//  MessagesAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/12/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

open class MessagesAPI {
    
    public enum MessageType: String {
        case message = "message"
        case action = "action"
    }
    
    public enum MessageStatisticsInterval: String {
        case minute = "minute"
        case hour = "hour"
        case day = "day"
        case month = "month"
        case year = "year"
    }
    
    // MARK: - Messages
    
    /// Send a Message to ARTIK Cloud.
    ///
    /// - Parameters:
    ///   - data: The message payload.
    ///   - did: The Device's id, used as the sender.
    ///   - timestamp: (Optional) Message timestamp. Must be a valid time: past time, present or future up to the current server timestamp grace period. Current time if omitted.
    /// - Returns: A `Promise<String>`, returning the resulting message's id.
    open class func sendMessage(data: [String:Any], fromDid did: String, timestamp: Int64? = nil) -> Promise<String> {
        let parameters: [String:Any] = [
            "data": data,
            "type": MessageType.message.rawValue,
            "sdid": did
        ]
        return postMessage(baseParameters: parameters, timestamp: timestamp)
    }
    
    /// Get the messages sent by a Device using pagination.
    ///
    /// - Parameters:
    ///   - did: The Device's id.
    ///   - startDate: Time of the earliest possible item, in milliseconds since epoch.
    ///   - endDate: Time of the latest possible item, in milliseconds since epoch.
    ///   - count: The count of results, max `100` (default).
    ///   - offset: (Optional) The offset cursor for pagination.
    ///   - order: (Optional) The order of the results, `.ascending` if ommited.
    ///   - fieldPresence: (Optional) Return only messages which contain the provided field names
    /// - Returns: A `Promise<MessagePage>`
    open class func getMessages(did: String, startDate: ArtikTimestamp, endDate: ArtikTimestamp, count: Int = 100, offset: String? = nil, order: PaginationOrder? = nil, fieldPresence: [String]? = nil) -> Promise<MessagePage> {
        let (promise, resolver) = Promise<MessagePage>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/messages"
        var presenceValue: String?
        if let fieldPresence = fieldPresence {
            presenceValue = "(" + fieldPresence.map { return "+_exists_:\($0)" }.joined(separator: " ") + ")"
        }
        let parameters = APIHelpers.removeNilParameters([
            "sdid": did,
            "startDate": startDate,
            "endDate": endDate,
            "count": count,
            "offset": offset,
            "order": order?.rawValue,
            "filter": presenceValue
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let page = MessagePage(JSON: response) {
                page.count = count
                page.fieldPresence = fieldPresence
                resolver.fulfill(page)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get a specific Message
    ///
    /// - Parameters:
    ///   - mid: The Message's id.
    ///   - uid: (Optional) The owner's user ID, required when using an `ApplicationToken`.
    /// - Returns: A `Promise<Message>`
    open class func getMessage(mid: String, uid: String? = nil) -> Promise<Message> {
        let (promise, resolver) = Promise<Message>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/messages"
        var parameters = [
            "mid": mid
        ]
        if let uid = uid {
            parameters["uid"] = uid
        }
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let data = (response["data"] as? [[String:Any]])?.first, let message = Message(JSON: data) {
                resolver.fulfill(message)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get the presence of Messages for a given time period.
    ///
    /// - Parameters:
    ///   - sdid: The source Device's id.
    ///   - fieldPresence: (Optional) Return only messages which contain the provided field name
    ///   - startDate: Time of the earliest possible item, in milliseconds since epoch.
    ///   - endDate: Time of the latest possible item, in milliseconds since epoch.
    ///   - interval: The grouping interval
    /// - Returns: A `Promise<MessagesPresence>`
    open class func getPresence(sdid: String?, fieldPresence: String? = nil, startDate: ArtikTimestamp, endDate: ArtikTimestamp, interval: MessageStatisticsInterval) -> Promise<MessagesPresence> {
        let (promise, resolver) = Promise<MessagesPresence>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/messages/presence"
        let parameters = APIHelpers.removeNilParameters([
            "sdid": sdid,
            "fieldPresence": fieldPresence,
            "interval": interval.rawValue,
            "startDate": startDate,
            "endDate": endDate
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let presence = MessagesPresence(JSON: response) {
                resolver.fulfill(presence)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get the latest messages sent by a Device.
    ///
    /// - Parameters:
    ///   - did: The Device's id
    ///   - count: The count of results, max 100
    ///   - fieldPresence: (Optional) Return only messages which contain the provided field names
    /// - Returns: A `Promise<MessagePage>`
    open class func getLastMessages(did: String, count: Int = 100, fieldPresence: [String]? = nil) -> Promise<MessagePage> {
        let (promise, resolver) = Promise<MessagePage>.pending()
        
        getMessages(did: did, startDate: 1, endDate: currentArtikEpochtime(), count: count, order: .descending, fieldPresence: fieldPresence).done { page in
            resolver.fulfill(page)
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get the lastest message sent by a Device.
    ///
    /// - Parameter did: The Device's id.
    /// - Returns: A `Promise<Message>`
    open class func getLastMessage(did: String) -> Promise<Message?> {
        let (promise, resolver) = Promise<Message?>.pending()
        
        getLastMessages(did: did, count: 1).done { page in
            if let message = page.data.first {
                resolver.fulfill(message)
            } else {
                resolver.fulfill(nil)
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Actions
    
    /// Send an Action to a Device through ARTIK Cloud.
    ///
    /// - Parameters:
    ///   - named: The name of the action
    ///   - parameters: (Optional) The parameters of the action.
    ///   - target: The Device's id receiving the action.
    ///   - sender: (Optional) The id of the Device sending the action.
    ///   - timestamp: (Optional) Action timestamp, a past/present/future time up to the current server timestamp grace period. Current time if omitted.
    /// - Returns: A `Promise<String>` returning the resulting action's id.
    open class func sendAction(named: String, parameters: [String:Any]? = nil, toDid target: String, fromDid sender: String? = nil, timestamp: Int64? = nil) -> Promise<String> {
        var parameters: [String:Any] = [
            "ddid": target,
            "type": MessageType.action.rawValue,
            "data": [
                "actions": [
                    [
                        "name": named,
                        "parameters": parameters ?? [:]
                    ]
                ]
            ]
        ]
        if let sender = sender {
            parameters["sdid"] = sender
        }
        return postMessage(baseParameters: parameters, timestamp: timestamp)
    }
    
    /// Send multiple Actions to a Device through ARTIK Cloud.
    ///
    /// - Parameters:
    ///   - actions: A dict where the `key` is the name of the action and the `value` is its parameters.
    ///   - target: The Device's id receiving the action.
    ///   - sender: (Optional) The id of the Device sending the action.
    ///   - timestamp: (Optional) Action timestamp, a past/present/future time up to the current server timestamp grace period. Current time if omitted.
    /// - Returns: A `Promise<String>` returning the resulting action's id.
    open class func sendActions(_ actions: [String:[String:Any]?], toDid target: String, fromDid sender: String? = nil, timestamp: Int64? = nil) -> Promise<String> {
        var data = [[String:Any]]()
        for (name, parameters) in actions {
            data.append([
                "name": name,
                "parameters": parameters ?? [:]
            ])
        }
        var parameters: [String:Any] = [
            "ddid": target,
            "type": MessageType.action.rawValue,
            "data": [
                "actions": data
            ]
        ]
        if let sender = sender {
            parameters["sdid"] = sender
        }
        return postMessage(baseParameters: parameters, timestamp: timestamp)
    }
    
    /// Get the actions sent to a Device.
    ///
    /// - Parameters:
    ///   - did: The Device's id
    ///   - startDate: Time of the earliest possible item, in milliseconds since epoch.
    ///   - endDate: Time of the latest possible item, in milliseconds since epoch.
    ///   - count: The count of results, max `100` (default).
    ///   - offset: (Optional) The offset cursor for pagination.
    ///   - order: (Optional) The order of the results, `.ascending` if ommited.
    ///   - name: (Optional) Return only actions with the provided name.
    /// - Returns: A `Promise<MessagePage>`
    open class func getActions(did: String, startDate: ArtikTimestamp, endDate: ArtikTimestamp, count: Int = 100, offset: String? = nil, order: PaginationOrder? = nil, name: String? = nil) -> Promise<MessagePage> {
        let (promise, resolver) = Promise<MessagePage>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/actions"
        let parameters = APIHelpers.removeNilParameters([
            "sdid": did,
            "startDate": startDate,
            "endDate": endDate,
            "count": count,
            "offset": offset,
            "order": order?.rawValue,
            "name": name
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let page = MessagePage(JSON: response) {
                page.count = count
                page.name = name
                resolver.fulfill(page)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get a particular action sent to a Device.
    ///
    /// - Parameters:
    ///   - mid: The Action's (message) id.
    ///   - uid: (Optional) The owner's user ID, required when using an `ApplicationToken`.
    /// - Returns: A `Promise<Message>`
    open class func getAction(mid: String, uid: String? = nil) -> Promise<Message> {
        let (promise, resolver) = Promise<Message>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/actions"
        var parameters = [
            "mid": mid
        ]
        if let uid = uid {
            parameters["uid"] = uid
        }
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let data = (response["data"] as? [[String:Any]])?.first, let message = Message(JSON: data) {
                resolver.fulfill(message)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get the latest actions sent to a Device.
    ///
    /// - Parameters:
    ///   - did: The Device's id.
    ///   - count: The count of results, max 100.
    ///   - name: (Optional) Return only actions with the provided name.
    /// - Returns: A `Promise<MessagePage>`
    open class func getLastActions(did: String, count: Int = 100, name: String? = nil) -> Promise<MessagePage> {
        let (promise, resolver) = Promise<MessagePage>.pending()
        
        getActions(did: did, startDate: 1, endDate: currentArtikEpochtime(), count: count, order: .descending, name: name).done { page in
            resolver.fulfill(page)
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get the latest action sent to a Device
    ///
    /// - Parameter did: The Device's id.
    /// - Returns: A `Promise<Message?>`
    open class func getLastAction(did: String) -> Promise<Message?> {
        let (promise, resolver) = Promise<Message?>.pending()
        
        getLastActions(did: did, count: 1).done { page in
            if let message = page.data.first {
                resolver.fulfill(message)
            } else {
                resolver.fulfill(nil)
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Analytics
    
    /// Get the sum, minimum, maximum, mean and count of message fields that are numerical. Values for `startDate` and `endDate` are rounded to start of minute, and the date range between `startDate` and `endDate` is restricted to 31 days max.
    ///
    /// - Parameters:
    ///   - sdid: The source Device's id.
    ///   - startDate: Time of the earliest possible item, in milliseconds since epoch.
    ///   - endDate: Time of the latest possible item, in milliseconds since epoch.
    ///   - field: Message field being queried for analytics.
    /// - Returns: A `Promise<MessageAggregates>`
    open class func getAggregates(sdid: String, startDate: ArtikTimestamp, endDate: ArtikTimestamp, field: String) -> Promise<MessageAggregates> {
        let (promise, resolver) = Promise<MessageAggregates>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/messages/analytics/aggregates"
        let parameters: [String:Any] = [
            "sdid": sdid,
            "startDate": startDate,
            "endDate": endDate,
            "field": field
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let aggregate = MessageAggregates(JSON: response) {
                resolver.fulfill(aggregate)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Returns message aggregates over equal intervals, which can be used to draw a histogram.
    ///
    /// - Parameters:
    ///   - sdid: The source Device's id.
    ///   - startDate: Time of the earliest possible item, in milliseconds since epoch.
    ///   - endDate: Time of the latest possible item, in milliseconds since epoch.
    ///   - interval: Interval on histogram X-axis.
    ///   - field: Message field being queried for histogram aggregation (histogram Y-axis).
    /// - Returns: A `Promise<MessageHistogram>`
    open class func getHistogram(sdid: String, startDate: ArtikTimestamp, endDate: ArtikTimestamp, interval: MessageStatisticsInterval, field: String) -> Promise<MessageHistogram> {
        let (promise, resolver) = Promise<MessageHistogram>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/messages/analytics/histogram"
        let parameters: [String:Any] = [
            "sdid": sdid,
            "startDate": startDate,
            "endDate": endDate,
            "interval": interval.rawValue,
            "field": field
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let histogram = MessageHistogram(JSON: response) {
                resolver.fulfill(histogram)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Snapshots
    
    /// Get the last received value for all Manifest fields (aka device "state") of devices.
    ///
    /// - Parameters:
    ///   - dids: An array containing the Devices' ids.
    ///   - includeTimestamp: (Optional) Include the timestamp of the last modification for each field.
    /// - Returns: A `Promise<[String:[String:Any]]>` where the `key` is the Device id and the `value` is its snapshot.
    open class func getSnapshots(dids: [String], includeTimestamp: Bool? = nil) -> Promise<[String:[String:Any]]> {
        let (promise, resolver) = Promise<[String:[String:Any]]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/messages/snapshots"
        
        if dids.count > 0 {
            var didsString = ""
            for did in dids {
                didsString += "\(did),"
            }
            
            APIHelpers.makeRequest(url: path, method: .get, parameters: ["sdids": didsString], encoding: URLEncoding.queryString).done { response in
                if let data = response["data"] as? [[String:Any]] {
                    var result = [String:[String:Any]]()
                    for item in data {
                        if let sdid = item["sdid"] as? String, let data = item["data"] as? [String:Any] {
                            result[sdid] = data
                        } else {
                            resolver.reject(ArtikError.json(reason: .invalidItem))
                            return
                        }
                    }
                    resolver.fulfill(result)
                } else {
                    resolver.reject(ArtikError.json(reason: .unexpectedFormat))
                }
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.fulfill([:])
        }
        return promise
    }
    
    /// Get the last received value for all Manifest fields (aka device "state") of a device.
    ///
    /// - Parameters:
    ///   - did: The Device's id.
    ///   - includeTimestamp: (Optional) Include the timestamp of the last modification for each field.
    /// - Returns: A `Promise<[String:Any]>` returning the snapshot
    open class func getSnapshot(did: String, includeTimestamp: Bool? = nil) -> Promise<[String:Any]> {
        let (promise, resolver) = Promise<[String:Any]>.pending()
        
        getSnapshots(dids: [did], includeTimestamp: includeTimestamp).done { result in
            if let snapshot = result[did] {
                resolver.fulfill(snapshot)
            } else {
                resolver.fulfill([:])
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Private Methods
    
    fileprivate class func currentArtikEpochtime() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000.0)
    }
    
    fileprivate class func postMessage(baseParameters: [String:Any], timestamp: Int64?) -> Promise<String> {
        let (promise, resolver) = Promise<String>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/messages"
        var parameters = baseParameters
        if let timestamp = timestamp {
            parameters["ts"] = timestamp
        }
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).done { response in
            if let mid = (response["data"] as? [String:Any])?["mid"] as? String {
                resolver.fulfill(mid)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
}
