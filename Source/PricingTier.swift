//
//  PricingTier.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 8/31/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper

open class PricingTier: Mappable {
    public var ptid: String?
    public var name: String?
    public var description: String?
    public var type: MonetizationAPI.PricingTierType?
    public var cost: Double?
    public var messageLimit: Int64?
    public var interval: MonetizationAPI.PricingTierInterval?
    public var billingInterval: MonetizationAPI.PricingTierBillingInterval?
    public var active: Bool?
    
    required public init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        ptid <- map["ptid"]
        name <- map["name"]
        description <- map["description"]
        type <- map["type"]
        cost <- map["cost"]
        messageLimit <- map["messageLimit"]
        interval <- map["interval"]
        billingInterval <- map["billingInterval"]
        active <- map["active"]
    }
}
