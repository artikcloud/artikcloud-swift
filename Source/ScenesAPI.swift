//
//  ScenesAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 12/11/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

open class ScenesAPI {
    
    /// Create a Scene.
    ///
    /// - Parameters:
    ///   - name: The name  of the scene.
    ///   - actions: The scene's actions definition.
    ///   - uid: (Optional) The User's ID, required if using an `ApplicationToken`.
    /// - Returns: A `Promise<Scene>`
    open class func create(name: String, description: String? = nil, actions: [[String:Any]], uid: String? = nil) -> Promise<Scene> {
        let (promise, resolver) = Promise<Scene>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/scenes"
        let parameters = APIHelpers.removeNilParameters([
            "name": name,
            "description": description,
            "actions": actions,
            "uid": uid
        ])
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let instance = Scene(JSON: data) {
                resolver.fulfill(instance)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Update a Scene.
    ///
    /// - Parameters:
    ///   - id: The scene's ID.
    ///   - name: (Optional) The scene's new name.
    ///   - actions: (Optional) The scene's new actions definition.
    ///   - uid: (Optional) The User's ID, required if using an `ApplicationToken`.
    /// - Returns: A `Promise<Scene>`
    open class func update(id: String, name: String? = nil, description: String? = nil, actions: [[String:Any]]? = nil, uid: String? = nil) -> Promise<Scene> {
        let (promise, resolver) = Promise<Scene>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/scenes"
        var parameters = APIHelpers.removeNilParameters([
            "name": name,
            "description": description,
            "actions": actions
        ])
        
        if parameters.count > 0 {
            if let uid = uid {
                parameters["uid"] = uid
            }
            
            APIHelpers.makeRequest(url: path, method: .put, parameters: parameters, encoding: JSONEncoding.default).done { response in
                if let data = response["data"] as? [String:Any], let instance = Scene(JSON: data) {
                    resolver.fulfill(instance)
                } else {
                    resolver.reject(ArtikError.json(reason: .unexpectedFormat))
                }
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            self.get(id: id).done { scene in
                resolver.fulfill(scene)
            }.catch { error -> Void in
                resolver.reject(error)
            }
        }
        return promise
    }
    
    /// Get a Scene
    ///
    /// - Parameter id: The scene's ID.
    /// - Returns: A `Promise<Scene>`
    open class func get(id: String) -> Promise<Scene> {
        let (promise, resolver) = Promise<Scene>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/scenes/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).done { response in
            if let data = response["data"] as? [String:Any], let instance = Scene(JSON: data) {
                resolver.fulfill(instance)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get a User's Scenes.
    ///
    /// - Parameters:
    ///   - uid: The User's ID.
    ///   - count: The count of results, max `100`.
    ///   - offset: The offset for pagination, default `0`.
    /// - Returns: A `Promise<Page<Scene>>`
    open class func get(uid: String, count: Int, offset: Int = 0) -> Promise<Page<Scene>> {
        let (promise, resolver) = Promise<Page<Scene>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/scenes"
        let parameters = [
            "count": count,
            "offset": offset
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let scenes = (response["data"] as? [String:Any])?["scenes"] as? [[String:Any]] {
                let page = Page<Scene>(offset: offset, total: total)
                if scenes.count != Int(count) {
                    resolver.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in scenes {
                    if let scene = Scene(JSON: item) {
                        page.data.append(scene)
                    } else {
                        resolver.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                resolver.fulfill(page)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Get all of a User's Scenes using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameter uid: The User's id.
    /// - Returns: A `Promise<Page<Scene>>`
    open class func get(uid: String) -> Promise<Page<Scene>> {
        return self.getRecursive(Page<Scene>(), uid: uid)
    }
    
    /// Remove a Scene.
    ///
    /// - Parameter id: The scene's ID.
    /// - Returns: A `Promise<Void>`
    open class func remove(id: String) -> Promise<Void> {
        return DevicesAPI.delete(id: id)
    }
    
    /// Activate a Scene.
    ///
    /// - Parameter id: The scene's ID.
    /// - Returns: A `Promise<Void>`
    open class func activate(id: String) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/scenes/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: nil, encoding: JSONEncoding.default).done { _ in
            resolver.fulfill(())
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Private Methods
    
    private class func getRecursive(_ container: Page<Scene>, uid: String, offset: Int = 0) -> Promise<Page<Scene>> {
        let (promise, resolver) = Promise<Page<Scene>>.pending()
        
        self.get(uid: uid, count: 100, offset: offset).done { result in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getRecursive(container, uid: uid, offset: Int(result.offset) + result.data.count).done { result in
                    resolver.fulfill(result)
                }.catch { error -> Void in
                    resolver.reject(error)
                }
            } else {
                resolver.fulfill(container)
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
}
