//
//  Rule.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/12/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
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
        let promise = Promise<Void>.pending()
        
        if let id = id {
            if isTestable ?? false {
                RulesAPI.testActions(id: id).then { _ -> Void in
                    promise.fulfill(())
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.reject(ArtikError.rule(reason: .oneOrMoreActionNotTestable))
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func getStatistics() -> Promise<RuleStatistics> {
        let promise = Promise<RuleStatistics>.pending()
        
        if let id = id {
            RulesAPI.getStatistics(id: id).then { results -> Void in
                promise.fulfill(results)
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    // MARK: - AccessibleArtikInstance
    
    public func updateOnArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            RulesAPI.update(id: id, name: name, uid: uid, description: description, rule: rule, enabled: enabled).then { result -> Void in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: result.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func pullFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            RulesAPI.get(id: id).then { rule -> Void in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: rule.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        
        return promise.promise
    }
    
    // MARK: - ManageableArtikInstance
    
    public func createOrDuplicateOnArtik() -> Promise<ManageableArtikInstance> {
        let promise = Promise<ManageableArtikInstance>.pending()
        
        if let name = name {
            if let rule = rule {
                RulesAPI.create(name: name, uid: uid, description: description, rule: rule, enabled: enabled ?? true).then { result -> Void in
                    promise.fulfill(result)
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.reject(ArtikError.missingValue(reason: .noRule))
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noName))
        }
        return promise.promise
    }
    
    public func removeFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            RulesAPI.remove(id: id).then { _ -> Void in
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
