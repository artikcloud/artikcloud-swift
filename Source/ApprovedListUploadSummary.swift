//
//  ApprovedListUploadSummary.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 2/1/18.
//  Copyright © 2018 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

public class ApprovedListUploadSummary: Mappable {
    
    public class VdidsCounts: Mappable {
        public var total: Int64?
        public var succeeded: Int64?
        public var failed: Int64?
        
        public required init?(map: Map) {}
        
        public init() {}
        
        public func mapping(map: Map) {
            total <- map["total"]
            succeeded <- map["succeeded"]
            failed <- map["failed"]
        }
    }
    
    public enum Status: String {
        case completed = "Completed"
        case processing = "Processing"
        case failed = "Failed"
    }
    
    public var id: String?
    public var status: Status?
    public var counts: VdidsCounts?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        id <- map["uploadId"]
        status <- map["status"]
        counts <- map["vdidsCount"]
    }
}
