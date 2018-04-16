//
//  Scene.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 12/11/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
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
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            ScenesAPI.activate(id: id).done {
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
    
    public func updateOnArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            ScenesAPI.update(id: id, name: name, description: description, actions: actions).done { _ in
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
            ScenesAPI.get(id: id).done { scene in
                self.mapping(map: Map(mappingType: .fromJSON, JSON: scene.toJSON(), toObject: true, context: nil, shouldIncludeNilValues: true))
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func removeFromArtik() -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        
        if let id = id {
            ScenesAPI.remove(id: id).done {
                resolver.fulfill(())
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noID))
        }
        return promise
    }
    
    public func createOrDuplicateOnArtik() -> Promise<ManageableArtikInstance> {
        let (promise, resolver) = Promise<ManageableArtikInstance>.pending()
        
        if let name = name {
            if let actions = actions {
                ScenesAPI.create(name: name, description: description, actions: actions, uid: uid).done { scene in
                    resolver.fulfill(scene)
                }.catch { error -> Void in
                    resolver.reject(error)
                }
            } else {
                resolver.reject(ArtikError.missingValue(reason: .noActions))
            }
        } else {
            resolver.reject(ArtikError.missingValue(reason: .noName))
        }
        return promise
    }
}
