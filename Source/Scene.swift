//
//  Scene.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 12/11/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import ObjectMapper
import PromiseKit

open class Scene: Mappable, ManageableArtikInstance {
    public var id: String?
    public var uid: String?
    public var aid: String?
    public var name: String?
    public var description: String?
    public var actions: [[String:Any]]?
    public var invalidatedOn: ArtikTimestamp?
    public var error: [String:Any]?
    
    public required init?(map: Map) {}
    
    public init() {}
    
    public func mapping(map: Map) {
        id <- map["id"]
        uid <- map["uid"]
        aid <- map["aid"]
        name <- map["name"]
        description <- map["description"]
        actions <- map["actions"]
        invalidatedOn <- map["invalidatedOn"]
        error <- map["error"]
    }
    
    public func activate() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            ScenesAPI.activate(id: id).then { _ -> Void in
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
    
    public func updateOnArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            ScenesAPI.update(id: id, name: name, description: description, actions: actions).then { _ -> Void in
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
            ScenesAPI.get(id: id).then { scene -> Void in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: scene.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func removeFromArtik() -> Promise<Void> {
        let promise = Promise<Void>.pending()
        
        if let id = id {
            ScenesAPI.remove(id: id).then { _ -> Void in
                promise.fulfill(())
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise.promise
    }
    
    public func createOrDuplicateOnArtik() -> Promise<ManageableArtikInstance> {
        let promise = Promise<ManageableArtikInstance>.pending()
        
        if let name = name {
            if let actions = actions {
                ScenesAPI.create(name: name, description: description, actions: actions, uid: uid).then { scene -> Void in
                    promise.fulfill(scene)
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.reject(ArtikError.missingValue(reason: .noActions))
            }
        } else {
            promise.reject(ArtikError.missingValue(reason: .noName))
        }
        return promise.promise
    }
}
