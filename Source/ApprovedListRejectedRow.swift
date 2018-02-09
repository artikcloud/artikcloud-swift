//
//  ApprovedListRejectedRow.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 2/1/18.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

public class ApprovedListRejectedRow: Mappable {
    public var index: Int64?
    public var message: String?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        index <- map["index"]
        message <- map["message"]
    }
}
