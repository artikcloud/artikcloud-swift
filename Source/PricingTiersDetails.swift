//
//  PricingTiersDetails.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 8/31/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper

open class PricingTiersDetails: Mappable {
    public var type: MonetizationAPI.PricingTiersDetailsType?
    public var tiers: [PricingTier]?
    public var contactInfo: PricingTierContactInfo?
    public var version: Int64?
    public var status: MonetizationAPI.PricingTiersDetailsStatus?
    public var comments: String?
    public var revenueSharePercent: Double?
    
    public class PricingTierContactInfo: Mappable {
        public var email: String?
        public var phone: String?
        
        public required init?(map: Map) {}
        
        public func mapping(map: Map) {
            email <- map["email"]
            phone <- map["phone"]
        }
    }
    
    required public init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        type <- map["type"]
        tiers <- map["tiers"]
        contactInfo <- map["contactInfo"]
        version <- map["version"]
        status <- map["status"]
        comments <- map["comments"]
        revenueSharePercent <- map["revenueSharePercent"]
    }
}
