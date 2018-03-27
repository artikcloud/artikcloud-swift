//
//  MonetizationAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/22/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
#if os(iOS)
import SafariServices
#endif

open class MonetizationAPI {
    
    public enum MonetizationUpgradeAction: String {
        case upgrade = "upgrade"
        case select = "select"
        case edit = "edit"
    }
    
    public enum MonetizationUpgradeResult: String {
        case accepted = "accepted"
        case declined = "declined"
        case failed = "failed"
    }
    
    public enum PricingTierType: String {
        case free = "free"
        case paid = "paid"
    }
    
    public enum PricingTierInterval: String {
        case daily = "DAILY"
    }
    
    public enum PricingTierBillingInterval: String {
        case once = "ONCE"
    }
    
    public enum PricingTiersDetailsType: String {
        case count = "count"
    }
    
    public enum PricingTiersDetailsStatus: String {
        case new = "NEW"
        case pending = "PENDING"
        case approved = "APPROVED"
        case rejected = "REJECTED"
    }
    
    // MARK: - Upgrade Flow
    
    /// If a device can be upgraded, returns a `URL` to be requested for the user, containing one of three phases of the upgrade flow.
    ///
    /// - Parameters:
    ///   - did: The Device's id.
    ///   - action: The desired upgrade phase on which to start.
    /// - Returns: A `Promise<URL>`
    open class func getUpgradeURL(did: String, action: MonetizationUpgradeAction = .upgrade) -> Promise<URL> {
        let promise = Promise<URL>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/pricing/devices/\(did)/revenueshare/upgradepath"
        let parameters = [
            "action": action.rawValue
        ]
        
        guard let redirect = ArtikCloudSwiftSettings.getRedirectURI(for: .monetization) else {
            promise.reject(ArtikError.artikCloudSwiftSettings(reason: .noRedirectURI))
            return promise.promise
        }
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let data = response["data"] as? [String:Any], let urlRaw = data["url"] as? String {
                if let url = URL(string: urlRaw + "?redirect_uri=\(redirect)") {
                    promise.fulfill(url)
                } else {
                    promise.reject(ArtikError.url(reason: .failedToInit))
                }
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        
        return promise.promise
    }
    
    #if os(iOS)
    /// If a device can be upgraded, returns a `SFSafariViewController` to be presented to the user, containing one of three phases of the upgrade flow.
    ///
    /// - Parameters:
    ///   - did: The Device's id.
    ///   - action: The desired upgrade phase on which to start
    /// - Returns: A `Promise<SFSafariViewController>`
    open class func getUpgradeController(did: String, action: MonetizationUpgradeAction = .upgrade) -> Promise<SFSafariViewController> {
        let promise = Promise<SFSafariViewController>.pending()
        
        getUpgradeURL(did: did, action: action).then { url -> Void in
            promise.fulfill(SFSafariViewController(url: url))
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    #endif
    
    /// Process a callback received for an Monetization Upgrade flow.
    ///
    /// - Parameter callback: The `URL` of the callback.
    /// - Returns: The result of the upgrade flow.
    /// - Throws: An `ArtikError` for any failures.
    open class func processUpgradeCallback(_ callback: URL) throws -> MonetizationUpgradeResult {
        let uriParameters = try ArtikCloudSwiftSettings.getRedirectURIParameters(callback, endpoint: .monetization)
        
        if let rawStatus = uriParameters["status"], let status = MonetizationUpgradeResult(rawValue: rawStatus) {
            return status
        }
        throw ArtikError.monetization(reason: .missingUpgradeStatus)
    }
    
    // MARK: - Get Tiers
    
    /// Get the Monetization Tiers of a Device Type.
    ///
    /// - Parameters:
    ///   - dtid: The Device Type's id.
    ///   - latest: (Optional) Return only the latest version.
    ///   - status: (Optional) Filter results by status.
    /// - Returns: A `Promise<[PricingTiersDetails]>`
    open class func getTiers(dtid: String, latest: Bool? = nil, status: PricingTiersDetailsStatus? = nil) -> Promise<[PricingTiersDetails]> {
        let promise = Promise<[PricingTiersDetails]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/pricing/devicetypes/\(dtid)/pricingtiers"
        let parameters = APIHelpers.removeNilParameters([
            "latest": latest,
            "status": status
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let pricingTiers = (response["data"] as? [String:Any])?["pricingTiers"] as? [[String:Any]] {
                var result = [PricingTiersDetails]()
                for json in pricingTiers {
                    if let tier = PricingTiersDetails(JSON: json) {
                        result.append(tier)
                    } else {
                        promise.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                promise.fulfill(result)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get the Monetization Tiers of a Device
    ///
    /// - Parameters:
    ///   - did: The Device's id
    ///   - active: (Optional) Filter results by their `active` state.
    /// - Returns: A `Promise<[PricingTier]>`
    open class func getTiers(did: String, active: Bool? = nil) -> Promise<[PricingTier]> {
        let promise = Promise<[PricingTier]>.pending()
        let path = ArtikCloudSwiftSettings.basePath + "/pricing/devices/\(did)/pricingtiers"
        let parameters = APIHelpers.removeNilParameters([
            "active": active
        ])
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: parameters, encoding: URLEncoding.queryString).then { response -> Void in
            if let pricingTiersJson = (response["data"] as? [String:Any])?["pricingTiers"] as? [[String:Any]] {
                var result = [PricingTier]()
                for json in pricingTiersJson {
                    if let tier = PricingTier(JSON: json) {
                        result.append(tier)
                    } else {
                        promise.reject(ArtikError.json(reason: .invalidItem))
                        return
                    }
                }
                promise.fulfill(result)
            } else {
                promise.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            promise.reject(error)
        }
        return promise.promise
    }
    
}
