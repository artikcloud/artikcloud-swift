//
//  Rule.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/12/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class Rule: Mappable, ManageableArtikInstance {
    public var createdOn: ArtikTimestamp?
    public var description: String?
    public var enabled: Bool?
    public var id: String?
    public var languageVersion: Int64?
    public var modifiedOn: ArtikTimestamp?
    public var name: String?
    public var rule: [String:Any]?
    public var uid: String?
    public var isTestable: Bool?
    public var aid: String?
    public var scope: RulesAPI.RuleScope?
    public var invalidatedOn: ArtikTimestamp?
    public var error: [String:Any]?
    
    required public init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        createdOn <- map["createdOn"]
        description <- map["description"]
        enabled <- map["enabled"]
        id <- map["id"]
        languageVersion <- map["languageVersion"]
        modifiedOn <- map["modifiedOn"]
        name <- map["name"]
        rule <- map["rule"] 
        uid <- map["uid"]
        isTestable <- map["isTestable"]
        aid <- map["aid"]
        scope <- map["scope"]
        invalidatedOn <- map["invalidatedOn"]
        error <- map["error"]
    }
    
    public func isWritable() -> Bool? {
        if let scope = scope {
            switch scope {
            case .unowned:
                return false
            default:
                return true
            }
        }
        return isFromCurrentApplication()
    }
    
    public func isFromCurrentApplication() -> Bool? {
        if let aid = aid {
            if let clientId = ArtikCloudSwiftSettings.clientID {
                return aid == clientId
            }
        }
        return nil
    }
    
    public func testActions() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            if isTestable ?? false {
                RulesAPI.testActions(id: id).done {
                    resolver.fulfill(())
                }.catch { error -> Void in
                    resolver.reject(error)
                }
            } else {
                resolver.reject(ArtikError.rule(reason: .oneOrMoreActionNotTestable))
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func getStatistics() -> Promise<RuleStatistics> {
        let (promise, resolver) = Promise<RuleStatistics>.pending()
        
        if let id = id {
            RulesAPI.getStatistics(id: id).done { results in
                resolver.fulfill(results)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - AccessibleArtikInstance
    
    public func updateOnArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            RulesAPI.update(id: id, name: name, uid: uid, description: description, rule: rule, enabled: enabled).done { result in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: result.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func pullFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            RulesAPI.get(id: id).done { rule in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: rule.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    // MARK: - ManageableArtikInstance
    
    public func createOrDuplicateOnArtik() -> Promise<ManageableArtikInstance> {
        let (promise, resolver) = Promise<ManageableArtikInstance>.pending()
        
        if let name = name {
            if let rule = rule {
                RulesAPI.create(name: name, uid: uid, description: description, rule: rule, enabled: enabled ?? true).done { result in
                    resolver.fulfill(result)
                }.catch { error -> Void in
                    resolver.reject(error)
                }
            } else {
                resolver.reject(ArtikError.missingValue(reason: .noRule))
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noName))
        }
        return promise
    }
    
    public func removeFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            RulesAPI.remove(id: id).done {
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
