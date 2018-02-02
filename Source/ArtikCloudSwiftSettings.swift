//
//  ArtikCloudSwiftSettings.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/12/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import PromiseKit

open class ArtikCloudSwiftSettings {
    public enum RedirectEndpoint: String {
        case `default` = ""
        case logout = "logout"
        case cloudAuthorization = "c2c"
        case monetization = "monetization"
    }
    
    // MARK: - General Settings
    
    public static weak var delegate: ArtikCloudSwiftDelegate?
    public static var trace: ((String) -> Void)?
    public static var attemptToRefreshToken = true
    public static var preferredTokenForRequests: Token.Type?
    public static var preferredTokenForWebsockets: Token.Type?
    
    // MARK: - ARTIK Application Settings
    
    public static var clientID: String?
    public static var clientSecret: String?
    public static var redirectURI: String?
    
    // MARK: - Endpoints
    
    internal static var basePath      = "https://api.artik.cloud/v1.1"
    internal static var authPath      = "https://accounts.artik.cloud"
    internal static var websocketPath = "wss://api.artik.cloud/v1.1"
    
    // MARK: - Private Settings
    
    fileprivate static var userToken: UserToken? {
        didSet {
            if userToken == nil {
                self.refreshPromise = nil
            }
        }
    }
    fileprivate static var applicationToken: ApplicationToken?
    fileprivate static var deviceToken: DeviceToken?
    fileprivate static var refreshPromise: Promise<Void>?
    
    // MARK: - User Token Access Methods
    
    /// Set the `UserToken` to be used when making requests with ARTIK Cloud.
    ///
    /// - Parameter token: A `UserToken` or `nil` to remove any currently used `UserToken`.
    open class func setUserToken(_ token: UserToken?) {
        userToken = token
    }
    
    /// Get the current `UserToken`.
    ///
    /// - Parameter andValidate: Whether or not the token should be validated locally before being returned.
    /// - Returns: A `Promise<UserToken?>`.
    open class func getUserToken(andValidate: Bool = true) -> Promise<UserToken?> {
        let promise = Promise<UserToken?>.pending()
        
        if let token = self.userToken {
            if andValidate {
                if token.isValid() {
                    promise.fulfill(token)
                } else if self.attemptToRefreshToken {
                    let refreshPromise = self.refreshPromise ?? token.refresh()
                    if self.refreshPromise == nil {
                        refreshPromise.always {
                            setUserToken(token)
                            delegate?.tokenRefreshed?(token)
                            self.refreshPromise = nil
                        }
                    }
                    
                    self.refreshPromise = refreshPromise.then { _ -> Void in
                        promise.fulfill(token)
                    }
                        
                    self.refreshPromise?.catch { error -> Void in
                        promise.reject(error)
                    }
                } else {
                    promise.reject(ArtikError.token(reason: .invalidToken))
                }
            } else {
                promise.fulfill(token)
            }
        } else {
            promise.fulfill(nil)
        }
        return promise.promise
    }
    
    // MARK: - Application Token Access Methods
    
    /// Set the `ApplicationToken` to be used when making requests with ARTIK Cloud.
    ///
    /// - Parameter token: A `ApplicationToken` or `nil` to remove any currently used `ApplicationToken`.
    open class func setApplicationToken(_ token: ApplicationToken?) {
        applicationToken = token
    }
    
    /// Get the current `ApplicationToken`.
    ///
    /// - Parameter andValidate: Whether or not the token should be validated locally before being returned.
    /// - Returns: An `ApplicationToken` or `nil`
    /// - Throws: `ArtikError.token(reason: .invalidToken)` if the token is invalid.
    open class func getApplicationToken(andValidate: Bool = true) throws -> ApplicationToken? {
        if let token = self.applicationToken {
            if andValidate {
                if token.isValid() {
                    return token
                } else {
                    throw ArtikError.token(reason: .invalidToken)
                }
            } else {
                return token
            }
        }
        return nil
    }
    
    // MARK: - Device Token Access Methods
    
    /// Set the `DeviceToken` to be used when making requests with ARTIK Cloud.
    ///
    /// - Parameter token: A `DeviceToken` or `nil` to remove any currently used `DeviceToken`.
    open class func setDeviceToken(_ token: DeviceToken?) {
        self.deviceToken = token
    }
    
    /// Get the current `DeviceToken`.
    ///
    /// - Returns: A `DeviceToken` or `nil`.
    open class func getDeviceToken() -> DeviceToken? {
        return self.deviceToken
    }
    
    // MARK: - Callback/Redirects Methods
    
    /// Using a callback `URL`, attempts to identify an ARTIK Cloud redirect flow and returns it if found.
    ///
    /// - Parameter callback: The callback `URL` received.
    /// - Returns: A `RedirectEndpoint` or `nil`
    open class func identifyRedirectEndpoint(_ callback: URL) -> RedirectEndpoint? {
        if let redirectURI = redirectURI, let redirectScheme = URL(string: redirectURI)?.scheme, let callbackScheme = callback.scheme, redirectScheme == callbackScheme {
            if let callbackHost = callback.host {
                if let result = RedirectEndpoint(rawValue: callbackHost) {
                    return result
                }
            } else {
                return .default
            }
        }
        return nil
    }
    
    /// Get the full redirect URI associated with an ARTIK redirect flow. Returns `nil` if no redirect URI is found in the settings.
    ///
    /// - Parameter endpoint: The desired endpoint/flow.
    /// - Returns: A `String` or `nil`
    open class func getRedirectURI(for endpoint: RedirectEndpoint) -> String? {
        if let redirectURI = redirectURI {
            return redirectURI + endpoint.rawValue
        }
        return nil
    }
    
    /// Get the parameters passed back in a callback `URL`.
    ///
    /// - Parameters:
    ///   - callback: The callback `URL` received.
    ///   - endpoint: The
    /// - Returns: The parameters in a `[String:String]`.
    /// - Throws: An `ArtikError` in case of failure.
    open class func getRedirectURIParameters(_ callback: URL, endpoint: RedirectEndpoint) throws -> [String:String] {
        if let redirectURI = self.getRedirectURI(for: endpoint) {
            let source = callback.absoluteString
            if source.count > redirectURI.count {
                let start = source.index(source.startIndex, offsetBy: redirectURI.count + 1)
                let pairs = source[start...].components(separatedBy: "&")
                
                var result = [String:String]()
                for pair in pairs {
                    let components = pair.components(separatedBy: "=")
                    if components.count == 2 {
                        result[components[0]] = components[1]
                    } else {
                        throw ArtikError.url(reason: .failedToParse)
                    }
                }
                return result
            } else {
                throw ArtikError.applicationCallback(reason: .doesNotMatchRedirectURI)
            }
        }
        throw ArtikError.swiftyArtikSettings(reason: .noRedirectURI)
    }
}
