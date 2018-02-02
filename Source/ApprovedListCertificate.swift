//
//  ApprovedListCertificate.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 2/1/18.
//  Copyright © 2018 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper

public class ApprovedListCertificate: Mappable {
    
    public class Validity: Mappable {
        public var notBefore: ArtikTimestamp?
        public var notAfter: ArtikTimestamp?
        
        public required init?(map: Map) {}
        
        public init() {}
        
        public func mapping(map: Map) {
            notBefore <- map["notBefore"]
            notAfter <- map["notAfter"]
        }
    }
    
    public var id: String?
    public var version: Int64?
    public var serialNumber: String?
    public var signatureAlgorithm: String?
    public var subject: String?
    public var issuer: String?
    public var validity: Validity?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        version <- map["certificateFields.version"]
        serialNumber <- map["certificateFields.serialNumber"]
        signatureAlgorithm <- map["certificateFields.signatureAlgorithm"]
        subject <- map["certificateFields.subject"]
        issuer <- map["certificateFields.issuer"]
        validity <- map["certificateFields.validity"]
    }
}
