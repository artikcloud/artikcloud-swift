//
//  RulesAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/12/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

open class RulesAPI {
    
    public enum RuleScope: String {
        case `public` = "allApplications"
        case publicOrOwned = "allApplications,thisApplication"
        case owned = "thisApplication" // private, owner is app
        case unowned = "otherApplications" // private, owner is not app
    }
    
    // MARK: - Public Methods
    
    /// Get a Rule using its id.
    ///
    /// - Parameter id: The Rule's id.
    /// - Returns: A `Promise<Rule>`
    open class func get(id: String) -> Promise<Rule> {
        let promise = Promise<Rule>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/rules/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let instance = Rule(JSON: data) {
                promise.fulfill(instance)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get a User's Rules using pagination.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - count: The course of results, max `100`.
    ///   - offset: The offset for pagination, default `0`.
    ///   - scope: The ownership scope of the Rules, default `.publicOrOwned`.
    ///   - excludeDisabled: Exclude disabled Rules from the results, default `false`.
    /// - Returns: A `Promise<Page<Rule>>`
    open class func get(uid: String, count: Int, offset: Int = 0, scope: RuleScope = .publicOrOwned, excludeDisabled: Bool = false) -> Promise<Page<Rule>> {
        let promise = Promise<Page<Rule>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/users/\(uid)/rules"
        let parameters: [String:Any] = [
            "count": count,
            "offset": offset,
            "excludeDisabled": excludeDisabled,
            "scope": scope.rawValue
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let data = response["data"] as? [Any] {
                let page = Page<Rule>(offset: offset, total: total)
                if data.count != Int(count) {
                    promise.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in data {
                    if let item = item as? [String:Any], let rule = Rule(JSON: item) {
                        page.data.append(rule)
                    } else {
                        promise.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                promise.fulfill(page)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get all of a User's Rules using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - uid: The User's id.
    ///   - scope: The ownership scope of the Rules, default `.publicOrOwned`.
    ///   - excludeDisabled: Exclude disabled Rules from the results, default `false`.
    /// - Returns: A `Promise<Page<Rule>>`
    open class func get(uid: String, scope: RuleScope = .publicOrOwned, excludeDisabled: Bool = false) -> Promise<Page<Rule>> {
        return getRecursive(Page<Rule>(), uid: uid, scope: scope, excludeDisabled: excludeDisabled)
    }
    
    /// Create a Rule.
    ///
    /// - Parameters:
    ///   - name: The name of the Rule.
    ///   - uid: (Optional) The User's id, required if using an `ApplicationToken`.
    ///   - description: (Optional) The description of the Rule.
    ///   - rule: The rule's definition.
    ///   - owner: The owner of the rule, default `.user`.
    ///   - enabled: If the Rule should be enabled upon creation, default `true`.
    /// - Returns: A `Promise<Rule>`
    open class func create(name: String, uid: String? = nil, description: String? = nil, rule: [String: Any], scope: RuleScope = .owned, enabled: Bool = true) -> Promise<Rule> {
        let promise = Promise<Rule>.pending()
        guard scope == .owned || scope == .public else {
            promise.reject(ArtikError.rule(reason: .invalidScopeProvided))
            return promise.promise
        }
        let path = ArtikCloudSwiftSettings.basePath + "/rules"
        let parameters = APIHelpers.removeNilParameters([
            "name": name,
            "uid": uid,
            "description": description,
            "rule": rule,
            "scope": scope.rawValue,
            "enabled": enabled
        ])
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let instance = Rule(JSON: data) {
                promise.fulfill(instance)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Update a Rule.
    ///
    /// - Parameters:
    ///   - id: The Rule's id.
    ///   - name: (Optional) The rule's new name.
    ///   - uid: (Optional) The User's id, required if using an `ApplicationToken`.
    ///   - description: (Optional) The rule's new description.
    ///   - rule: (Optional) The rule's new definition.
    ///   - owner: (Optional) The rule's new owner.
    ///   - enabled: (Optional) THe rule's new enabled value.
    /// - Returns: A `Promise<Rule>`
    open class func update(id: String, name: String? = nil, uid: String? = nil, description: String? = nil, rule: [String: Any]? = nil, scope: RuleScope? = nil, enabled: Bool? = nil) -> Promise<Rule> {
        let promise = Promise<Rule>.pending()
        if let scope = scope {
            guard scope == .owned || scope == .public else {
                promise.reject(ArtikError.rule(reason: .invalidScopeProvided))
                return promise.promise
            }
        }
        let path = ArtikCloudSwiftSettings.basePath + "/rules/\(id)"
        let parameters = APIHelpers.removeNilParameters([
            "name": name,
            "uid": uid,
            "description": description,
            "rule": rule,
            "scope": scope?.rawValue,
            "enabled": enabled
        ])
        
        if parameters.count > 0 {
            APIHelpers.makeRequest(url: path, method: .put, parameters: parameters, encoding: JSONEncoding.default).then { response -> Void in
                if let data = response["data"] as? [String:Any], let instance = Rule(JSON: data) {
                    promise.fulfill(instance)
                } else {
                    promise.reject(ArtikError.json(reason: .unexpectedFormat))
                }
            }.catch { error -> Void in
                promise.reject(error)
            }
        } else {
            get(id: id).then { rule -> Void in
                promise.fulfill(rule)
            }.catch { error -> Void in
                promise.reject(error)
            }
        }
        return promise.promise
    }
    
    /// Remove a Rule.
    ///
    /// - Parameter id: The Rule's id.
    /// - Returns: A `Promise<Void>`.
    open class func remove(id: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/rules/\(id)"
        
        APIHelpers.makeRequest(url: path, method: .delete, parameters: nil, encoding: URLEncoding.default).then { _ -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get a Rule's executions' statistics.
    ///
    /// - Parameter id: The Rule's id.
    /// - Returns: A `Promise<RuleStatistics>`.
    open class func getStatistics(id: String) -> Promise<RuleStatistics> {
        let promise = Promise<RuleStatistics>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/rules/\(id)/executions"
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default).then { response -> Void in
            if let data = response["data"] as? [String:Any], let stats = RuleStatistics(JSON: data) {
                promise.fulfill(stats)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Test a Rule's Actions, if possible.
    ///
    /// - Parameter id: The Rule's id.
    /// - Returns: A `Promise<Void>`.
    open class func testActions(id: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/rules/\(id)/actions"
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: nil, encoding: URLEncoding.default).then { _ -> Void in
            promise.fulfill(())
        }.catch { error -> Void in
            if let error = error as? AFError, let code = error.responseCode {
                if code == 400 {
                    promise.reject(ArtikError.rule(reason: .oneOrMoreActionNotTestable))
                    return
                }
            }
            promise.reject(error)
        }
        return promise.promise
    }
    
    // MARK: - Private Methods
    
    private class func getRecursive(_ container: Page<Rule>, uid: String, offset: Int = 0, scope: RuleScope = .publicOrOwned, excludeDisabled: Bool = false) -> Promise<Page<Rule>> {
        let promise = Promise<Page<Rule>>.pending()
        
        RulesAPI.get(uid: uid, count: 100, offset: offset, scope: scope, excludeDisabled: excludeDisabled).then { result -> Void in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getRecursive(container, uid: uid, offset: Int(result.offset) + result.data.count, scope: scope, excludeDisabled: excludeDisabled).then { result -> Void in
                    promise.fulfill(result)
                }.catch { error -> Void in
                    promise.reject(error)
                }
            } else {
                promise.fulfill(container)
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
}
