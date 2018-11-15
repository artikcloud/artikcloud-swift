//
//  APIHelpers.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/15/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

public typealias JSONResponse = [String: Any]
public typealias RequestMethod = HTTPMethod
public typealias RequestEncoding = ParameterEncoding
public typealias ArtikTimestamp = Int64 // Epoch Milliseconds
public typealias ArtikRequestCount = UInt64

internal class APIHelpers {
    static var authorizationHeaderKey = "Authorization"
    
    enum APIResponseHeaderKey: String {
        case payload = "X-Quota-Max-Payload-Size"
        case organizationLimits = "X-Quota-Organization-Limits"
        case organizationReset = "X-Quota-Organization-Reset"
        case limitLimit = "X-Rate-Limit-Limit"
        case limitRemaining = "X-Rate-Limit-Remaining"
        case limitReset = "X-Rate-Limit-Reset"
        case deviceLimits = "X-Quota-Device-Limits"
        case deviceReset = "X-Quota-Device-Reset"
    }
    
    enum ResponseHeaderStatus {
        case rateLimitMinuteReached(resetIn: Int64)
        case rateLimitDailyReached(resetIn: Int64)
        case organizationQuotaReached(ends: ArtikTimestamp)
        case deviceQuotaReached(quota: UInt64, ends: ArtikTimestamp)
        case nothingWrong
    }
    
    // MARK: - Request Makers
    
    class func makeRequest(url: URLConvertible, method: RequestMethod, parameters: [String: Any]?, encoding: RequestEncoding, includeAuthHeader: Bool = true, additionalHeaders headers: [String:String]? = nil) -> Promise<JSONResponse> {
        let (promise, resolver) = Promise<JSONResponse>.pending()
        let closure: (([String:String]?) -> (Void)) = { headers in
            let trace: ((Bool, Error?, JSONResponse?) -> (String)) = { success, error, json in
                return getTrace(isSuccess: success, url: url, method: method, parameters: parameters, encoding: encoding, headers: headers, error: error, json: json)
            }
            
            Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON { response -> Void in
                processResponse(response, resolver: resolver, trace: trace)
            }
        }
        execute(closure, resolver: resolver, headers: headers, includeAuthHeader: includeAuthHeader)
        return promise
    }
    
    // MARK: - File Uploaders
    
    class func uploadData(_ data: Data, to url: URLConvertible, method: RequestMethod, includeAuthHeader: Bool = true, additionalHeaders headers: [String:String]? = nil) -> Promise<JSONResponse> {
        let (promise, resolver) = Promise<JSONResponse>.pending()
        let closure: (([String:String]?) -> (Void)) = { headers in
            let trace: ((Bool, Error?, JSONResponse?) -> (String)) = { success, error, json in
                return getTrace(isSuccess: success, url: url, method: method, parameters: nil, encoding: nil, headers: headers, error: error, json: json)
            }
            
            Alamofire.upload(data, to: url, method: method, headers: headers).validate().responseJSON { response -> Void in
                processResponse(response, resolver: resolver, trace: trace)
            }
        }
        execute(closure, resolver: resolver, headers: headers, includeAuthHeader: includeAuthHeader)
        return promise
    }
    
    // MARK: - Internal Helper Methods
    
    class func removeNilParameters(_ parameters: [String:Any?]) -> [String:Any] {
        var result = [String:Any]()
        for (key, value) in parameters {
            if let value = value {
                result[key] = value
            }
        }
        return result
    }
    
    class func getClientIdAndClientSecretEncodedHeaderValue() throws -> String? {
        if let clientID = ArtikCloudSwiftSettings.clientID, let clientSecret = ArtikCloudSwiftSettings.clientSecret {
            if let data = "\(clientID):\(clientSecret)".data(using: .utf8) {
                return "Basic \(data.base64EncodedString())"
            }
            throw ArtikError.artikCloudSwiftSettings(reason: .clientIdAndClientSecretCouldNotBeEncoded)
        }
        return nil
    }
    
    class func getAuthToken(preference: Token.Type? = nil) -> Promise<Token?> {
        let (promise, resolver) = Promise<Token?>.pending()
        var skipApplication = false
        var skipDevice = false
        
        if preference != nil {
            if let _ = preference as? UserToken.Type {
                ArtikCloudSwiftSettings.getUserToken().done { token in
                    do {
                        if let token = token {
                            resolver.fulfill(token)
                        } else if let token = try ArtikCloudSwiftSettings.getApplicationToken() {
                            resolver.fulfill(token)
                        } else if let token = ArtikCloudSwiftSettings.getDeviceToken() {
                            resolver.fulfill(token)
                        } else {
                            resolver.fulfill(nil)
                        }
                    } catch {
                        resolver.reject(error)
                    }
                }.catch { error -> Void in
                    resolver.reject(error)
                }
                return promise
            } else if let _ = preference as? ApplicationToken.Type {
                do {
                    if let token = try ArtikCloudSwiftSettings.getApplicationToken() {
                        resolver.fulfill(token)
                        return promise
                    }
                    skipApplication = true
                } catch {
                    resolver.reject(error)
                    return promise
                }
            } else if let _ = preference as? DeviceToken.Type {
                if let token = ArtikCloudSwiftSettings.getDeviceToken() {
                    resolver.fulfill(token)
                    return promise
                }
                skipDevice = true
            }
        }
        
        ArtikCloudSwiftSettings.getUserToken().done { token in
            do {
                if let token = token {
                    resolver.fulfill(token)
                } else if !skipApplication, let token = try ArtikCloudSwiftSettings.getApplicationToken() {
                    resolver.fulfill(token)
                } else if !skipDevice, let token = ArtikCloudSwiftSettings.getDeviceToken() {
                    resolver.fulfill(token)
                } else {
                    resolver.fulfill(nil)
                }
            } catch {
                resolver.reject(error)
            }
        }.catch { error -> Void in
            resolver.reject(error)
        }
        return promise
    }
    
    // MARK: - Private Methods
    
    fileprivate class func execute(_ completion: @escaping (([String:String]?) -> (Void)), resolver: Resolver<JSONResponse>, headers: [String:String]?, includeAuthHeader: Bool) {
        if includeAuthHeader {
            getAuthToken(preference: ArtikCloudSwiftSettings.preferredTokenForRequests).done { token in
                if let token = token {
                    var allHeaders = (headers ?? [String:String]())
                    allHeaders[self.authorizationHeaderKey] = token.getHeaderValue()
                    completion(allHeaders)
                } else {
                    completion(headers)
                }
            }.catch { error -> Void in
                resolver.reject(error)
            }
        } else {
            completion(headers)
        }
    }
    
    fileprivate class func processResponse(_ response: DataResponse<Any>, resolver: Resolver<JSONResponse>, trace: @escaping ((Bool, Error?, JSONResponse?) -> (String)), attemptsLeft: Int = ArtikCloudSwiftSettings.rateLimitAttemptsCount) {
        var responseHeaderStatus: ResponseHeaderStatus?
        if let _ = ArtikCloudSwiftSettings.delegate {
            responseHeaderStatus = processResponseHeaders(response.response?.allHeaderFields)
        }
        
        switch response.result {
        case .success(let JSON):
            if let JSON = JSON as? JSONResponse {
                ArtikCloudSwiftSettings.trace?(trace(true, nil, JSON))
                resolver.fulfill(JSON)
            } else {
                let error = ArtikError.json(reason: .unexpectedFormat)
                ArtikCloudSwiftSettings.trace?(trace(true, error, nil))
                resolver.reject(error)
            }
        case .failure(let error):
            var jsonResponse: JSONResponse?
            if let data = response.data, let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:Any] {
                ArtikCloudSwiftSettings.trace?(trace(false, error, json))
                jsonResponse = json
            } else {
                ArtikCloudSwiftSettings.trace?(trace(false, error, nil))
            }
            
            if let error = error as? AFError, let code = error.responseCode {
                if code == 429 {
                    let status = responseHeaderStatus ?? processResponseHeaders(response.response?.allHeaderFields)
                    let retryOrReject: (_ reset: Int64, _ reject: () -> ()) -> () = { reset, reject in
                        if let request = response.request, attemptsLeft > 0, reset < ArtikCloudSwiftSettings.rateLimitAttemptsThreshold {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(reset))) {
                                Alamofire.request(request).validate().responseJSON { response in
                                    processResponse(response, resolver: resolver, trace: trace, attemptsLeft: attemptsLeft - 1)
                                }
                            }
                        } else {
                            reject()
                        }
                    }
                    
                    switch status {
                    case .deviceQuotaReached(let quota, let ends):
                        var target: String?
                        if let error = jsonResponse?["error"] as? [String:Any], let message = error["message"] as? String {
                            let leading = message.components(separatedBy: "Plan quota exceeded for device ")
                            if leading.count > 1 {
                                let trailing = leading[1].components(separatedBy: ". Reason: Daily message limit.")
                                if let did = trailing.first {
                                    target = did
                                }
                            }
                        }
                        resolver.reject(ArtikError.rateLimit(reason: .deviceQuotaReached(did: target, quota: quota, ends: ends)))
                        return
                    case .organizationQuotaReached(let ends):
                        resolver.reject(ArtikError.rateLimit(reason: .organizationQuotaReached(ends: ends)))
                        return
                    case .rateLimitMinuteReached(let reset):
                        retryOrReject(reset) {
                            resolver.reject(ArtikError.rateLimit(reason: .rateLimitMinuteReached(resetIn: reset)))
                        }
                        return
                    case .rateLimitDailyReached(let reset):
                        retryOrReject(reset) {
                            resolver.reject(ArtikError.rateLimit(reason: .rateLimitDailyReached(resetIn: reset)))
                        }
                        return
                    default:
                        break
                    }
                }
            }
            resolver.reject(ArtikError.responseError(error: error, response: jsonResponse))
        }
    }
    
    fileprivate class func processResponseHeaders(_ headers: [AnyHashable: Any]?) -> ResponseHeaderStatus {
        var result = ResponseHeaderStatus.nothingWrong
        if let headers = headers {
            if ArtikCloudSwiftSettings.delegate?.maxPayload != nil,
                let quotaMaxPayload = headers[APIResponseHeaderKey.payload.rawValue] as? UInt64 {
                ArtikCloudSwiftSettings.delegate?.maxPayload(quotaMaxPayload)
            }
            if let quotaDeviceLimits = headers[APIResponseHeaderKey.deviceLimits.rawValue] as? String,
                let quotaDeviceReset = headers[APIResponseHeaderKey.deviceReset.rawValue] as? String {
                let quota = APIDeviceQuota(limits: quotaDeviceLimits, reset: quotaDeviceReset)
                if let quota = quota {
                    ArtikCloudSwiftSettings.delegate?.deviceQuota(quota)
                    
                    if quota.limit.current > quota.limit.max {
                        result = .deviceQuotaReached(quota: quota.limit.max, ends: quota.reset)
                    }
                }
            }
            if let quotaOrganizationLimits = headers[APIResponseHeaderKey.organizationLimits.rawValue] as? String,
                let quotaOrganizationReset = headers[APIResponseHeaderKey.organizationReset.rawValue] as? String {
                let quota = APIOrganizationQuota(limits: quotaOrganizationLimits, reset: quotaOrganizationReset)
                if let quota = quota {
                    ArtikCloudSwiftSettings.delegate?.organizationQuota(quota)
                    
                    if quota.limit.current > quota.limit.max {
                        result = .organizationQuotaReached(ends: quota.end)
                    }
                }
            }
            if let rateLimitLimit = headers[APIResponseHeaderKey.limitLimit.rawValue] as? String,
                let rateLimitRemaining = headers[APIResponseHeaderKey.limitRemaining.rawValue] as? String,
                let rateLimitReset = headers[APIResponseHeaderKey.limitReset.rawValue] as? String {
                let rate = APIRateLimit(limit: rateLimitLimit, remaining: rateLimitRemaining, reset: rateLimitReset)
                if let rate = rate {
                    ArtikCloudSwiftSettings.delegate?.rateLimit(rate)
                    
                    if rate.remaining.slidingMinute == 0 {
                        result = .rateLimitMinuteReached(resetIn: rate.reset.slidingMinute)
                    } else if rate.remaining.daily == 0 {
                        result = .rateLimitDailyReached(resetIn: rate.reset.daily)
                    }
                }
            }
        }
        return result
    }
    
    fileprivate class func getTrace(isSuccess: Bool, url: URLConvertible, method: RequestMethod, parameters: [String: Any]?, encoding: RequestEncoding?, headers: [String:String]?, error: Error?, json: JSONResponse?) -> String {
        let tab = "    "
        let dtab = tab + tab
        var text = "ARTIK Cloud:\n" + tab +
            "\(encoding != nil ? "Request" : "Upload"): [\(isSuccess ? "SUCCESS" : "FAILURE")]:\n" + dtab +
            "- URL: \(url)\n" + dtab +
            "- Method: \(method.rawValue)\n" + dtab +
            "- Headers: \(headers ?? [:])\n"
        if let encoding = encoding {
            text += dtab + "- Encoding: \(encoding)\n"
                  + dtab + "- Parameters: \(parameters ?? [:])\n"
        }
        
        text += tab + "Response:\n" + dtab
        if let error = error {
            text += "- Error: \(error)\n" + dtab
        }
        if let json = json {
            text += "- JSON: \(json)"
        } else {
            text += "- JSON: nil"
        }
        return text
    }
    
}
