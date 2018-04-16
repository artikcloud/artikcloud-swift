//
//  DeviceManagementTasks.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 1/12/18.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class DeviceManagementTask: Mappable {
    
    public enum TaskType: String {
        case read = "R"
        case write = "W"
        case execute = "E"
    }
    
    public enum TaskStatus: String {
        case requested = "REQUESTED"
        case queuing = "QUEUING"
        case processing = "PROCESSING"
        case complete = "COMPLETE"
        case cancelled = "CANCELLED"
    }
    
    open class TaskState: Mappable {
        public var status: TaskStatus?
        public var ts: ArtikTimestamp?
        public var errorCode: Int64?
        public var errorMessage: String?
        public var attempts: Int64?
        
        public required init?(map: Map) {}
        
        public init() {}
        
        public func mapping(map: Map) {
            status <- map["status"]
            ts <- map["ts"]
            errorCode <- map["errorCode"]
            errorMessage <- map["errorMessage"]
            attempts <- map["numAttempts"]
        }
    }
    
    open class TaskStatusCounts: Mappable {
        public var totalDevices: Int64?
        public var completed: Int64?
        public var succeeded: Int64?
        public var failed: Int64?
        public var cancelled: Int64?
        
        public required init?(map: Map) {}
        
        public init() {}
        
        public func mapping(map: Map) {
            totalDevices <- map["totalDevices"]
            completed <- map["numCompleted"]
            succeeded <- map["numSucceeded"]
            failed <- map["numFailed"]
            cancelled <- map["numCancelled"]
        }
    }
    
    public var id: String?
    public var dtid: String?
    public var dids: [String]?
    public var filter: String?
    public var type: TaskType?
    public var property: String?
    public var parameters: [String:Any]?
    public var status: TaskStatus?
    public var createdOn: ArtikTimestamp?
    public var modifiedOn: ArtikTimestamp?
    public var needsAcceptance: Bool?
    public var counts: TaskStatusCounts?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        dtid <- map["dtid"]
        dids <- map["dids"]
        filter <- map["filter"]
        type <- map["taskType"]
        property <- map["property"]
        parameters <- map["taskParameters"]
        status <- map["status"]
        createdOn <- map["createdOn"]
        modifiedOn <- map["modifiedOn"]
        needsAcceptance <- map["needsAcceptance"]
        counts <- map["statusCounts"]
    }
}
