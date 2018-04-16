//
//  Message.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/13/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class Message: Mappable, PullableArtikInstance {
    public var mid: String?
    public var type: MessagesAPI.MessageType?
    public var ddid: String?
    public var ddtid: String?
    public var sdid: String?
    public var sdtid: String?
    public var mv: Int64?
    public var data: [String:Any]?
    public var ts: Int64?
    public var cts: Int64?
    public var uid: String?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        mid <- map["mid"]
        sdid <- map["sdid"]
        ddid <- map["ddid"]
        sdtid <- map["sdtid"]
        ddtid <- map["ddtid"]
        mv <- map["mv"]
        data <- map["data"]
        ts <- map["ts"]
        cts <- map["cts"]
        uid <- map["uid"]
    }
    
    // MARK: - PullableArtikInstance
    
    public func pullFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = mid {
            MessagesAPI.getMessage(mid: id).done { message in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: message.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
}
