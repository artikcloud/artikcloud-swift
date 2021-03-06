//
//  AuthenticationAPI.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 9/5/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import CryptoSwift
#if os(iOS)
import SafariServices
#endif

open class AuthenticationAPI {
    fileprivate static var code_verifier: String?
    
    public enum AccountType: String {
        case artik = "ARTIKCLOUD"
        case samsung = "SAMSUNG"
        case google = "GOOGLE"
        case naver = "NAVER"
    }
    
    public enum ResponseType: String {
        case code = "code"
        case token = "token"
    }
    
    public enum LoginEndpoint: String {
        case signin = "/signin"
        case authorize = "/authorize"
    }
    
    public enum GrantType: String {
        case authenticationCode = "authorization_code"
        case clientCredentials = "client_credentials"
        case deviceCode = "device_code"
    }
    
    // MARK: - Authorization Code
    
    /// Get a URL to request a user to login using the Authorization Code method.
    ///
    /// - Parameters:
    ///   - pkce: Enable Proof Key for Code Exchange (PKCE)
    ///   - ignoreCurrentSession: Force the user to login again, regardless of any active sessions
    ///   - accountType: (Optional) Restrict login to an account type.
    ///   - state: (Optional) A value (must be URL-safe) that is passed back to you when the flow is over.
    /// - Returns: The `URL` to present to the user
    /// - Throws: `ArtikError`
    open class func getAuthorizationCodeURL(usingPKCE pkce: Bool, ignoreCurrentSession: Bool = false, accountType: AccountType? = nil, state: String? = nil) throws -> URL {
        guard let clientID = ArtikCloudSwiftSettings.clientID else {
            throw ArtikError.artikCloudSwiftSettings(reason: .noClientID)
        }
        if !pkce {
            guard let _ = ArtikCloudSwiftSettings.clientSecret else {
                throw ArtikError.artikCloudSwiftSettings(reason: .noClientSecret)
            }
        }
        
        var path = ArtikCloudSwiftSettings.authPath + (ignoreCurrentSession ? LoginEndpoint.signin.rawValue : LoginEndpoint.authorize.rawValue)
        var parameters = [
            "client_id": clientID,
            "response_type": ResponseType.code.rawValue
        ]
        
        if let redirectURI = ArtikCloudSwiftSettings.getRedirectURI(for: .default) {
            parameters["redirect_uri"] = redirectURI
        }
        
        if let accountType = accountType {
            parameters["account_type"] = accountType.rawValue
        }
        
        if let state = state {
            parameters["state"] = state
        }
        
        if pkce {
            var buffer1 = [UInt8](repeating: 0, count: 64)
            if SecRandomCopyBytes(kSecRandomDefault, buffer1.count, &buffer1) == 0 {
                code_verifier = Data(bytes: buffer1).base64EncodedString()
                    .replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: "=", with: "")
                    .trimmingCharacters(in: .whitespaces)
                
                if let hash = code_verifier!.data(using: .ascii)?.sha256() {
                    parameters["code_challenge"] = hash.base64EncodedString()
                        .replacingOccurrences(of: "+", with: "-")
                        .replacingOccurrences(of: "/", with: "_")
                        .replacingOccurrences(of: "=", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    
                } else {
                    code_verifier = nil
                    throw ArtikError.authorizationCodeAuthentication(reason: .failedToHashVerifier)
                }
            } else {
                throw ArtikError.authorizationCodeAuthentication(reason: .failedToGenerateVerifier)
            }
            parameters["code_challenge_method"] = "S256"
        }
        
        path += try convertParametersToString(parameters)
        if let result = URL(string: path) {
            return result
        }
        throw ArtikError.url(reason: .failedToInit)
    }
    
    #if os(iOS)
    /// Get a `SFSafariViewController` to request a user to login using the Authorization Code method.
    ///
    /// - Parameters:
    ///   - pkce: Enable Proof Key for Code Exchange (PKCE)
    ///   - ignoreCurrentSession: Force the user to login again, regardless of any active sessions
    ///   - accountType: (Optional) Restrict login to an account type.
    ///   - state: (Optional) A value (must be URL-safe) that is passed back to you when the flow is over.
    /// - Returns: The `SFSafariViewController` to present to the user
    /// - Throws: `ArtikError`
    open class func getAuthorizationCodeController(usingPKCE pkce: Bool, ignoreCurrentSession: Bool = false, accountType: AccountType? = nil, state: String? = nil) throws -> SFSafariViewController {
        let url = try self.getAuthorizationCodeURL(usingPKCE: pkce, ignoreCurrentSession: ignoreCurrentSession, accountType: accountType, state: state)
        return SFSafariViewController(url: url)
    }
    #endif
    
    /// Process a callback received for an Authorization Code authentication flow.
    ///
    /// - Parameters:
    ///   - callback: The `URL` of the callback
    ///   - pkce: Enable Proof Key for Code Exchange (PKCE), required if the flow was initiated with it
    /// - Returns: A `Promise` containing the resulting `UserToken`
    open class func processAuthorizationCodeCallback(_ callback: URL, usingPKCE pkce: Bool) -> Promise<UserToken> {
        let (promise, resolver) = Promise<UserToken>.pending()
        guard let clientID = ArtikCloudSwiftSettings.clientID else {
            resolver.reject(ArtikError.artikCloudSwiftSettings(reason: .noClientID))
            return promise
        }
        
        do {
            let uriParameters = try ArtikCloudSwiftSettings.getRedirectURIParameters(callback, endpoint: .default)
            if let code = uriParameters["code"] {
                let path = ArtikCloudSwiftSettings.authPath + "/token"
                var headers: [String:String]?
                var parameters = APIHelpers.removeNilParameters([
                    "grant_type": GrantType.authenticationCode.rawValue,
                    "code": code,
                    "state": uriParameters["state"]
                ])
                
                if pkce {
                    guard let code_verifier = self.code_verifier else {
                        resolver.reject(ArtikError.authorizationCodeAuthentication(reason: .codeVerifierNotFound))
                        return promise
                    }
                    parameters["client_id"] = clientID
                    parameters["code_verifier"] = code_verifier
                } else if let _ = ArtikCloudSwiftSettings.clientSecret, let headerValue = try APIHelpers.getClientIdAndClientSecretEncodedHeaderValue() {
                    headers = [APIHelpers.authorizationHeaderKey: headerValue]
                } else {
                    resolver.reject(ArtikError.artikCloudSwiftSettings(reason: .noClientSecret))
                    return promise
                }
                
                APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: URLEncoding.queryString, includeAuthHeader: false, additionalHeaders: headers).done { response in
                    code_verifier = nil
                    if let token = UserToken(JSON: response) {
                        token.setExpireTimestamp()
                        resolver.fulfill(token)
                    } else {
                        resolver.reject(ArtikError.json(reason: .unexpectedFormat))
                    }
                }.catch { error -> Void in
                    code_verifier = nil
                    resolver.reject(error)
                }
            } else {
                resolver.reject(ArtikError.applicationCallback(reason: .missingDeviceCode))
            }
        } catch {
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Implicit
    
    /// Get a URL to request a user to login using the Implicit method.
    ///
    /// - Parameters:
    ///   - ignoreCurrentSession: Force the user to login again, regardless of any active sessions
    ///   - accountType: (Optional) Restrict login to an account type.
    ///   - state: (Optional) A value (must be URL-safe) that is passed back to you when the flow is over.
    /// - Returns: The `URL` to present to the user
    /// - Throws: `ArtikError`
    open class func getImplicitURL(ignoreCurrentSession: Bool = false, accountType: AccountType? = nil, state: String? = nil) throws -> URL {
        guard let clientID = ArtikCloudSwiftSettings.clientID else {
            throw ArtikError.artikCloudSwiftSettings(reason: .noClientID)
        }
        
        var path = ArtikCloudSwiftSettings.authPath + (ignoreCurrentSession ? LoginEndpoint.signin.rawValue : LoginEndpoint.authorize.rawValue)
        var parameters = [
            "client_id": clientID,
            "response_type": ResponseType.token.rawValue
        ]
        
        if let redirectURI = ArtikCloudSwiftSettings.getRedirectURI(for: .default) {
            parameters["redirect_uri"] = redirectURI
        }
        
        if let accountType = accountType {
            parameters["account_type"] = accountType.rawValue
        }
        
        if let state = state {
            parameters["state"] = state
        }
        
        path += try convertParametersToString(parameters)
        if let result = URL(string: path) {
            return result
        }
        throw ArtikError.url(reason: .failedToInit)
    }
    
    #if os(iOS)
    /// Get a `SFSafariViewController` to request a user to login using the Implicit method.
    ///
    /// - Parameters:
    ///   - ignoreCurrentSession: Force the user to login again, regardless of any active sessions
    ///   - accountType: (Optional) Restrict login to an account type.
    ///   - state: (Optional) A value (must be URL-safe) that is passed back to you when the flow is over.
    /// - Returns: The `SFSafariViewController` to present to the user
    /// - Throws: `ArtikError`
    open class func getImplicitController(ignoreCurrentSession: Bool = false, accountType: AccountType? = nil, state: String? = nil) throws -> SFSafariViewController {
        let url = try self.getImplicitURL(ignoreCurrentSession: ignoreCurrentSession, accountType: accountType, state: state)
        return SFSafariViewController(url: url)
    }
    #endif
    
    /// Process a callback received for an Authorization Code authentication flow.
    ///
    /// - Parameter callback: The `URL` of the callback
    /// - Returns: A `Promise` containing the resulting `UserToken`
    /// - Throws: `ArtikError`
    open class func processImplicitCallback(_ callback: URL) throws -> UserToken {
        let parameters = try ArtikCloudSwiftSettings.getRedirectURIParameters(callback, endpoint: .default)
        if let token = UserToken(JSON: parameters) {
            token.setExpireTimestamp()
            return token
        }
        throw ArtikError.applicationCallback(reason: .containsInvalidToken)
    }
    
    // MARK: - Limited Input
    
    /// Get a `LimitedInputCode` and use it to prompt the user to enter the code at its verification URL.
    ///
    /// - Returns: The `LimitedInputCode`
    open class func getLimitedInputCode() -> Promise<LimitedInputCode> {
        let (promise, resolver) = Promise<LimitedInputCode>.pending()
        guard let clientID = ArtikCloudSwiftSettings.clientID else {
            resolver.reject(ArtikError.artikCloudSwiftSettings(reason: .noClientID))
            return promise
        }
        guard let _ = ArtikCloudSwiftSettings.clientSecret else {
            resolver.reject(ArtikError.artikCloudSwiftSettings(reason: .noClientSecret))
            return promise
        }
        
        let path = ArtikCloudSwiftSettings.authPath + "/device/code"
        let parameters = [
            "client_id": clientID
        ]
        
        APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: URLEncoding.queryString, includeAuthHeader: false).done { response in
            if let limitedInputCode = LimitedInputCode(JSON: response) {
                resolver.fulfill(limitedInputCode)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    /// Poll for a `UserToken` using a `LimitedInputCode` used in the Limited Input authentication method.
    ///
    /// - Parameter limitedInputCode: The `LimitInputCode` presented to the user
    /// - Parameter attempts: The amount of times it will try to poll with the given `LimitedInputCode`'s interval
    /// - Returns: A `Promise<UserToken>`. Errors specific to this flow are rejected as `ArtikError.limitedInputAuthentication`
    open class func pollForUserToken(using limitedInputCode: LimitedInputCode, attempts: UInt = 10) -> Promise<UserToken> {
        let (promise, resolver) = Promise<UserToken>.pending()
        let path = ArtikCloudSwiftSettings.authPath + "/token"
        
        if let code = limitedInputCode.deviceCode, let interval = limitedInputCode.interval {
            let parameters = [
                "grant_type": GrantType.deviceCode.rawValue,
                "code": code
            ]
            
            do {
                if let headerValue = try APIHelpers.getClientIdAndClientSecretEncodedHeaderValue() {
                    let headers = [APIHelpers.authorizationHeaderKey: headerValue]
                    
                    APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: URLEncoding.queryString, includeAuthHeader: false, additionalHeaders: headers).done { response in
                        if let token = UserToken(JSON: response) {
                            token.setExpireTimestamp()
                            resolver.fulfill(token)
                        } else {
                            resolver.reject(ArtikError.json(reason: .unexpectedFormat))
                        }
                    }.catch { error -> Void in
                        if let error = error as? ArtikError, case .responseError(_, let response) = error {
                            if let title = response?["error"] as? String {
                                switch title {
                                case "access_denied":
                                    resolver.reject(ArtikError.limitedInputAuthentication(reason: .accessDenied))
                                    return
                                case "authorization_pending":
                                    if attempts > 0 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(interval)), execute: {
                                            pollForUserToken(using: limitedInputCode, attempts: attempts - 1).done { token in
                                                resolver.fulfill(token)
                                            }.catch { error -> Void in
                                                resolver.reject(error)
                                            }
                                        })
                                    } else {
                                        resolver.reject(ArtikError.limitedInputAuthentication(reason: .pending))
                                    }
                                    return
                                case "slow_down":
                                    resolver.reject(ArtikError.limitedInputAuthentication(reason: .slowDown))
                                    return
                                case "expired_token":
                                    resolver.reject(ArtikError.limitedInputAuthentication(reason: .expiredCode))
                                    return
                                default:
                                    break
                                }
                            }
                        }
                        resolver.reject(error)
                    }
                } else {
                    resolver.reject(ArtikError.artikCloudSwiftSettings(reason: .noClientSecret))
                }
            } catch {
                resolver.reject(error)
            }
        } else {
            resolver.reject(ArtikError.limitedInputAuthentication(reason: .missingDeviceCode))
        }
        return promise
    }
    
    // MARK: - Client Credentials
    
    /// Get an `ApplicationToken` using the Client Credentials method.
    ///
    /// - Returns: The resulting `ApplicationToken`
    open class func getApplicationToken() -> Promise<ApplicationToken> {
        let (promise, resolver) = Promise<ApplicationToken>.pending()
        let path = ArtikCloudSwiftSettings.authPath + "/token"
        let parameters = [
            "grant_type": GrantType.clientCredentials.rawValue
        ]
        
        do {
            if let headerValue = try APIHelpers.getClientIdAndClientSecretEncodedHeaderValue() {
                APIHelpers.makeRequest(url: path, method: .post, parameters: parameters, encoding: URLEncoding.queryString, includeAuthHeader: false, additionalHeaders: [APIHelpers.authorizationHeaderKey: headerValue]).done { response in
                    if let token = ApplicationToken(JSON: response) {
                        token.setExpireTimestamp()
                        resolver.fulfill(token)
                    } else {
                        resolver.reject(ArtikError.json(reason: .unexpectedFormat))
                    }
                }.catch { error -> Void in
                    resolver.reject(error)
                }
            } else {
                resolver.reject(ArtikError.artikCloudSwiftSettings(reason: .noClientSecret))
            }
        } catch {
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Logout
    
    /// Get a `URL` to logout any currently logged in user.
    ///
    /// - Returns: The `URL` to request
    /// - Throws: `ArtikError`
    open class func getLogoutURL() throws -> URL {
        var path = ArtikCloudSwiftSettings.authPath + "/logout"
        if let redirectURI = ArtikCloudSwiftSettings.getRedirectURI(for: .logout)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            path += "?redirect_uri=\(redirectURI)"
        }
        if let result = URL(string: path) {
            return result
        }
        throw ArtikError.url(reason: .failedToInit)
    }
    
    #if os(iOS)
    /// Get a `SFSafariViewController` to logout any currently logged in user.
    ///
    /// - Returns: The `SFSafariViewController` to present
    /// - Throws: `ArtikError`
    open class func getLogoutController() throws -> SFSafariViewController {
        return SFSafariViewController(url: try self.getLogoutURL())
    }
    #endif
    
    // MARK: - Token Management
    
    /// Validate a `Token` with ARTIK Cloud
    ///
    /// - Parameter token: The `Token`
    /// - Returns: A `Promise` with the results of the validation
    open class func validateToken(_ token: Token) -> Promise<TokenValidation> {
        let (promise, resolver) = Promise<TokenValidation>.pending()
        let path = ArtikCloudSwiftSettings.authPath + "/tokenInfo"
        let headers: [String:String] = [
            APIHelpers.authorizationHeaderKey: token.getHeaderValue()
        ]
        
        APIHelpers.makeRequest(url: path, method: .get, parameters: nil, encoding: URLEncoding.default, includeAuthHeader: false, additionalHeaders: headers).done { response in
            if let data = response["data"] as? [String:Any], let validation = TokenValidation(JSON: data) {
                resolver.fulfill(validation)
            } else {
                resolver.reject(ArtikError.json(reason: .unexpectedFormat))
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    
    /// Revoke a `UserToken` on ARTIK Cloud
    ///
    /// - Parameter token: The `UserToken`
    /// - Returns: A `Promise<Void>`
    open class func revokeUserToken(_ token: UserToken) -> Promise<Void> {
        let (promise, resolver) = Promise<Void>.pending()
        let path = ArtikCloudSwiftSettings.authPath + "/revokeToken"
        let headers: [String:String] = [
            APIHelpers.authorizationHeaderKey: token.getHeaderValue()
        ]
        
        APIHelpers.makeRequest(url: path, method: .put, parameters: nil, encoding: URLEncoding.default, includeAuthHeader: false, additionalHeaders: headers).done { _ in
            resolver.fulfill(())
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Private Helpers
    
    private class func convertParametersToString(_ parameters: [String:String]) throws -> String {
        var path = ""
        var isFirstParam = true
        for (key, value) in parameters {
            if isFirstParam {
                path += "?"
                isFirstParam = false
            } else {
                path += "&"
            }
            if let component = "\(key)=\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                path += component
            } else {
                throw ArtikError.url(reason: .failedToEncode)
            }
        }
        return path
    }
}
