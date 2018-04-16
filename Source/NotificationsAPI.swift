//
//  NotificationsAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 8/31/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

open class NotificationsAPI {
    
    // MARK: - Get Messages
    
    /// Get the Messages associated with a notification using pagination.
    ///
    /// - Parameters:
    ///   - nid: The Notification's id
    ///   - count: The count of results, max `100`
    ///   - offset: The offset for pagination, default: `0`
    ///   - order: The order of the results, default: `.ascending`
    /// - Returns: A `Promise<Page<Message>>`
    open class func getMessages(nid: String, count: Int, offset: Int = 0, order: PaginationOrder = .ascending) -> Promise<Page<Message>> {
        let (promise, resolver) = Promise<Page<Message>>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/notifications/\(nid)/messages"
        let parameters: [String:Any] = [
            "count": count,
            "offset": offset,
            "order": order.rawValue
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).done { response in
            if let total = response["total"] as? Int64, let offset = response["offset"] as? Int64, let count = response["count"] as? Int64, let messages = response["data"] as? [[String:Any]] {
                let page = Page<Message>(offset: offset, total: total)
                if messages.count != Int(count) {
                    resolver.reject(ArtikError.json(reason: .countAndContentDoNotMatch))
                    return
                }
                for item in messages {
                    if let message = Message(JSON: item) {
                        page.data.append(message)
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
    
    /// Get the Messages associated with a notification using recursive requests.
    /// WARNING: May strongly impact your rate limit and quota.
    ///
    /// - Parameters:
    ///   - nid: The Notification's id
    ///   - order: The order of the results, default: `.ascending`
    /// - Returns: A `Promise<Page<Message>>`
    open class func getMessages(nid: String, order: PaginationOrder = .ascending) -> Promise<Page<Message>> {
        return self.getMessagesRecursive(Page<Message>(), nid: nid, order: order)
    }
    
    // MARK: - Private Helpers
    
    private class func getMessagesRecursive(_ container: Page<Message>, offset: Int = 0, nid: String, order: PaginationOrder) -> Promise<Page<Message>> {
        let (promise, resolver) = Promise<Page<Message>>.pending()
        
        self.getMessages(nid: nid, count: 100, offset: offset, order: order).done { result in
            container.data.append(contentsOf: result.data)
            container.total = result.total
            
            if container.total > Int64(container.data.count) {
                self.getMessagesRecursive(container, offset: Int(result.offset) + result.data.count, nid: nid, order: order).done { result in
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
