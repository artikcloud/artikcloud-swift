//
//  PaginationTypes.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/12/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

public enum PaginationOrder: String {
    case ascending = "asc"
    case descending = "desc"
}

open class Page<Element> {
    public var data = [Element]()
    public var offset: Int64 = 0
    public var total: Int64 = 0
    public var order: PaginationOrder?
    
    public init() {}
    
    public init(offset: Int64, total: Int64) {
        self.offset = offset
        self.total = total
    }
}

open class DeviceManagementTaskPage: Page<DeviceManagementTask> {
    public var scheduled: Int64 = 0
    public var requested: Int64 = 0
    public var queuing: Int64 = 0
    public var processing: Int64 = 0
    public var complete: Int64 = 0
    public var cancelled: Int64 = 0
    
    public override init() {
        super.init()
    }
    
    public init(offset: Int64, total: Int64, scheduled: Int64, requested: Int64, queuing: Int64, processing: Int64, complete: Int64, cancelled: Int64) {
        super.init(offset: offset, total: total)
        self.scheduled = scheduled
        self.requested = requested
        self.queuing = queuing
        self.processing = processing
        self.complete = complete
        self.cancelled = cancelled
    }
}

open class MessagePage: Mappable {
    public var uid: String?
    public var did: String?
    public var type: MessagesAPI.MessageType?
    public var order: PaginationOrder?
    public var data = [Message]()
    public var startDate: ArtikTimestamp?
    public var endDate: ArtikTimestamp?
    public var prev: String?
    public var next: String?
    internal var count: Int?
    internal var fieldPresence: [String]?
    internal var name: String?
    
    fileprivate var _ddid: String? {
        set {
            if let newValue = newValue {
                self.type = .action
                self.did = newValue
            }
        }
        
        get {
            if (type ?? .action) == .action {
                return self.did
            }
            return nil
        }
    }
    
    fileprivate var _sdid: String? {
        set {
            if let newValue = newValue {
                self.type = .message
                self.did = newValue
            }
        }
        
        get {
            if (type ?? .message) == .message {
                return self.did
            }
            return nil
        }
    }
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        uid <- map["uid"]
        _ddid <- map["ddid"]
        _sdid <- map["sdid"]
        order <- map["order"]
        data <- map["data"]
        startDate <- map["startDate"]
        endDate <- map["endDate"]
        prev <- map["prev"]
        next <- map["next"]
    }
    
    public func nextPage() -> Promise<MessagePage> {
        let promise = Promise<MessagePage>.pending()
        
        if let did = did {
            if let startDate = startDate {
                if let endDate = endDate {
                    if let cursor = next {
                        if (type ?? .message) == .message {
                            MessagesAPI.getMessages(did: did, startDate: startDate, endDate: endDate, count: count ?? 100, offset: cursor, order: order, fieldPresence: fieldPresence).then { page -> Void in
                                promise.fulfill(page)
                            }.catch { error -> Void in
                                promise.reject(error)
                            }
                        } else {
                            MessagesAPI.getActions(did: did, startDate: startDate, endDate: endDate, count: count ?? 100, offset: cursor, order: order, name: name).then { page -> Void in
                                promise.fulfill(page)
                            }.catch { error -> Void in
                                promise.reject(error)
                            }
                        }
                    } else {
                        promise.reject(ArtikError.missingValue(reason: .noOffsetCursor))
                    }
                } else {
                    promise.reject(ArtikError.missingValue(reason: .noEndDate))
                }
            } else {
                promise.reject(ArtikError.missingValue(reason: .noStartDate))
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func previousPage() -> Promise<MessagePage> {
        let promise = Promise<MessagePage>.pending()
        
        if let did = did {
            if let startDate = startDate {
                if let endDate = endDate {
                    if let cursor = prev {
                        if (type ?? .message) == .message {
                            MessagesAPI.getMessages(did: did, startDate: startDate, endDate: endDate, count: count ?? 100, offset: cursor, order: order, fieldPresence: fieldPresence).then { page -> Void in
                                promise.fulfill(page)
                            }.catch { error -> Void in
                                promise.reject(error)
                            }
                        } else {
                            MessagesAPI.getActions(did: did, startDate: startDate, endDate: endDate, count: count ?? 100, offset: cursor, order: order, name: name).then { page -> Void in
                                promise.fulfill(page)
                            }.catch { error -> Void in
                                promise.reject(error)
                            }
                        }
                    } else {
                        promise.reject(ArtikError.missingValue(reason: .noOffsetCursor))
                    }
                } else {
                    promise.reject(ArtikError.missingValue(reason: .noEndDate))
                }
            } else {
                promise.reject(ArtikError.missingValue(reason: .noStartDate))
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
}
