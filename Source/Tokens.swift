//
//  Tokens.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/12/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import PromiseKit
import ObjectMapper
import Alamofire


// MARK: - Base Token Classes

open class Token: NSObject, Mappable {
    public var accessToken: String!
    public var type: String!
    
    public override init() {
        super.init()
    }
    
    public required init?(map: Map) {}
    
    public func mapping(map: Map) {
        accessToken <- map["access_token"]
        type <- map["token_type"]
    }
    
    public func getHeaderValue() -> String {
        return "\(type!) \(accessToken!)"
    }
    
    public func validateToken() -> Promise<TokenValidation> {
        return AuthenticationAPI.validateToken(self)
    }
}

open class TokenExpiring: Token {
    public var expiresIn: Int64!
    public var expiresOnEpoch: ArtikTimestamp?
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        expiresIn <- map["expires_in"]
    }
    
    public func isValid() -> Bool {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000.0)
        return (expiresOnEpoch ?? -1) > timestamp
    }
    
    public func setExpireTimestamp() {
        if let expiresIn = expiresIn {
            let timestamp = Int64(Date().timeIntervalSince1970 * 1000.0)
            expiresOnEpoch = timestamp + expiresIn * 1000
        } else {
            expiresOnEpoch = nil
        }
    }
    
    public func validateToken(andUpdateInstance: Bool) -> Promise<TokenValidation> {
        let promise = Promise<TokenValidation>.pending()
        
        AuthenticationAPI.validateToken(self).then { validation -> Void in
            if andUpdateInstance {
                if let expiresIn = validation.expiresIn {
                    self.expiresIn = expiresIn
                    self.setExpireTimestamp()
                    promise.fulfill(validation)
                } else {
                    promise.reject(ArtikError.missingValue(reason: .noExpiresIn))
                }
            } else {
                promise.fulfill(validation)
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
}

// MARK: - UserToken

open class UserToken: TokenExpiring, NSCoding {
    public var refreshToken: String?
    public var scope: String?
    
    struct PropertyKey {
        static let accessToken_key = "_accessToken"
        static let refreshToken_key = "_refreshToken"
        static let expiresIn_key = "_expiresIn"
        static let expiresOnEpoch_key = "_expiresOnEpoch"
        static let type_key = "_type"
        static let scope_key = "_scope"
    }
    
    public init(accessToken: String, type: String, expiresIn: Int64, refreshToken: String? = nil, scope: String = "read,write") {
        super.init()
        self.accessToken = accessToken
        self.type = type
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        self.scope = scope
    }
    
    // MARK: Mappable
    
    public override init() {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init()
    }
    
    public override func mapping(map: Map) {
        super.mapping(map: map)
        refreshToken <- map["refresh_token"]
        scope <- map["scope"]
    }
    
    // MARK: NSCoding
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(accessToken, forKey: PropertyKey.accessToken_key)
        aCoder.encode(scope, forKey: PropertyKey.scope_key)
        aCoder.encode(type, forKey: PropertyKey.type_key)
        aCoder.encode(refreshToken, forKey: PropertyKey.refreshToken_key)
        aCoder.encode(expiresIn, forKey: PropertyKey.expiresIn_key)
        aCoder.encode(expiresOnEpoch, forKey: PropertyKey.expiresOnEpoch_key)
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        self.init()
        accessToken = aDecoder.decodeObject(forKey: PropertyKey.accessToken_key) as? String
        scope = aDecoder.decodeObject(forKey: PropertyKey.scope_key) as? String
        type = aDecoder.decodeObject(forKey: PropertyKey.type_key) as? String
        refreshToken = aDecoder.decodeObject(forKey: PropertyKey.refreshToken_key) as? String
        expiresIn = aDecoder.decodeObject(forKey: PropertyKey.expiresIn_key) as? Int64
        expiresOnEpoch = aDecoder.decodeObject(forKey: PropertyKey.expiresOnEpoch_key) as? ArtikTimestamp
    }
    
    // MARK: Misc.
    
    public func refresh() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let refreshToken = refreshToken {
            let path = ArtikCloudSwiftSettings.basePath + "/accounts/token"
            var header: [String:String]?
            let parameters = [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
            
            do {
                if let value = try APIHelpers.getClientIdAndClientSecretEncodedHeaderValue() {
                    header = [APIHelpers.authorizationHeaderKey: value]
                } else {
                    header = [APIHelpers.authorizationHeaderKey: getHeaderValue()]
                }
            } catch {
                promise.reject(error)
                return promise.promise
            }
            
            APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, includeAuthHeader: false, additionalHeaders: header).then { response -> Void in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: response, toObject: true, shouldIncludeNilValues: true))
                self.setExpireTimestamp()
                if !self.isValid() {
                    promise.reject(ArtikError.token(reason: .failedToRefresh))
                } else {
                    promise.fulfill(())
                }
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.token(reason: .noRefreshToken))
        }
        return promise.promise
    }
    
    public func revokeToken() -> Promise<Void> {
        return AuthenticationAPI.revokeUserToken(self)
    }
    
}

// MARK: - ApplicationToken

open class ApplicationToken: TokenExpiring {
    // Nothing to add
}

// MARK: - DeviceToken

open class DeviceToken: Token {
    public var uid: String?
    public var did: String?
    public var cid: String?
    
    public override func mapping(map: Map) {
        accessToken <- map["accessToken"]
        type = "bearer"
        uid <- map["uid"]
        did <- map["did"]
        cid <- map["cid"]
    }
    
    public func revokeToken() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        if let did = did {
            DevicesAPI.revokeToken(id: did).then { _ -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
}
