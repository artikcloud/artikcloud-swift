//
//  ArtikError.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 9/8/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation

public enum ArtikError: Error {
    
    // MARK: - General Error
    
    case responseError(error: Error, response: JSONResponse?)
    
    public var isResponseError: Bool {
        if case .responseError = self { return true }
        return false
    }
    
    // MARK: - ARTIK API Errors
    
    case rateLimit(reason: RateLimitReason)
    
    public enum RateLimitReason {
        case rateLimitMinuteReached
        case rateLimitDailyReached
        case organizationQuotaReached
        case deviceQuotaReached(did: String?, quota: UInt64)
    }
    
    public var isRateLimitError: Bool {
        if case .rateLimit = self { return true }
        return false
    }
    
    // MARK: - SDK Errors
    
    case artikCloudSwiftSettings(reason: ArtikCloudSwiftSettingsReason)
    
    public enum ArtikCloudSwiftSettingsReason {
        case noUserToken
        case noApplicationToken
        case noRedirectURI
        case noClientID
        case noClientSecret
        case clientIdAndClientSecretCouldNotBeEncoded
    }
    
    public var isArtikCloudSwiftSettingsError: Bool {
        if case .artikCloudSwiftSettings = self { return true }
        return false
    }
    
    case applicationCallback(reason: ApplicationCallbackReason)
    
    public enum ApplicationCallbackReason {
        case missingDeviceCode
        case containsInvalidToken
        case doesNotMatchRedirectURI
    }
    
    public var isApplicationCallbackError: Bool {
        if case .applicationCallback = self { return true }
        return false
    }
    
    case authorizationCodeAuthentication(reason: AuthorizationCodeAuthenticationReason)
    
    public enum AuthorizationCodeAuthenticationReason {
        case codeVerifierNotFound
        case failedToHashVerifier
        case failedToGenerateVerifier
    }
    
    public var isAuthorizationCodeAuthenticationError: Bool {
        if case .authorizationCodeAuthentication = self { return true }
        return false
    }
    
    case limitedInputAuthentication(reason: LimitedInputAuthenticationReason)
    
    public enum LimitedInputAuthenticationReason {
        case missingDeviceCode
        case accessDenied
        case pending
        case slowDown
        case expiredCode
    }
    
    public var isLimitedInputAuthenticationError: Bool {
        if case .limitedInputAuthentication = self { return true }
        return false
    }
    
    case token(reason: TokenReason)
    
    public enum TokenReason {
        case invalidToken
        case noRefreshToken
        case failedToRefresh
    }
    
    public var isTokenError: Bool {
        if case .token = self { return true }
        return false
    }
    
    case missingValue(reason: MissingValueReason)
    
    public enum MissingValueReason {
        case noID
        case noName
        case noAvailability
        case noSdid
        case noStartDate
        case noEndDate
        case noField
        case noInterval
        case noRule
        case noExpiresIn
        case noEmailOrInvalid
        case noOffsetCursor
        case noActions
    }
    
    public var isMissingValueError: Bool {
        if case .missingValue = self { return true }
        return false
    }
    
    case json(reason: JSONReason)
    
    public enum JSONReason {
        case unexpectedFormat
        case invalidItem
        case countAndContentDoNotMatch
    }
    
    public var isJSONError: Bool {
        if case .json = self { return true }
        return false
    }
    
    case url(reason: URLReason)
    
    public enum URLReason {
        case failedToInit
        case failedToEncode
        case failedToParse
    }
    
    public var isURLError: Bool {
        if case .url = self { return true }
        return false
    }
    
    case deviceType(reason: DeviceTypeReason)
    
    public enum DeviceTypeReason {
        case approvedListFailedToEncode
    }
    
    public var isDeviceTypeError: Bool {
        if case .deviceType = self { return true }
        return false
    }
    
    case monetization(reason: MonetizationReason)
    
    public enum MonetizationReason {
        case missingUpgradeStatus
    }
    
    public var isMonetizationError: Bool {
        if case .monetization = self { return true }
        return false
    }
    
    case rule(reason: RuleReason)
    
    public enum RuleReason {
        case oneOrMoreActionNotTestable
        case invalidScopeProvided
    }
    
    public var isRuleError: Bool {
        if case .rule = self { return true }
        return false
    }
    
    case subscription(reason: SubscriptionReason)
    
    public enum SubscriptionReason {
        case cannotUseBothSdtidAndSdid
    }
    
    public var isSubscriptionError: Bool {
        if case .subscription = self { return true }
        return false
    }
    
    case machineLearning(reason: MachineLearningReason)
    
    public enum MachineLearningReason {
        case invalidPredictIn
        case invalidSensitivity
    }
    
    public var isMachineLearningError: Bool {
        if case .machineLearning = self { return true }
        return false
    }
    
    case deviceManagement(reason: DeviceManagementReason)
    
    public enum DeviceManagementReason {
        case invalidPmin
        case invalidPmax
        case invalidTaskExpiresAfter
    }
    
    public var isDeviceManagementError: Bool {
        if case .deviceManagement = self { return true }
        return false
    }
    
    case websocket(reason: WebsocketReason)
    
    public enum WebsocketReason {
        case receivedAckError(code: Int, message: String)
        case unableToSerializeReceivedData
        case unableToEncodeMessage
        case socketIsNotConnected
        case tokenRequired
        case responseTimedout
        case unexpectedResponse
        case writeAlreadyOngoing
        case pingTimeout
    }
    
    public var isWebsocketError: Bool {
        if case .websocket = self { return true }
        return false
    }
}

extension ArtikError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .responseError(let error, let response):
            var description = "ARTIK API Response Failure.\n    Error: \(error.localizedDescription)"
            if let response = response {
                description += "\n    Response: \(response)"
            }
            return description
        case .rateLimit(let reason):
            return reason.localizedDescription
        case .artikCloudSwiftSettings(let reason):
            return reason.localizedDescription
        case .applicationCallback(let reason):
            return reason.localizedDescription
        case .authorizationCodeAuthentication(let reason):
            return reason.localizedDescription
        case .limitedInputAuthentication(let reason):
            return reason.localizedDescription
        case .token(let reason):
            return reason.localizedDescription
        case .missingValue(let reason):
            return reason.localizedDescription
        case .json(let reason):
            return reason.localizedDescription
        case .url(let reason):
            return reason.localizedDescription
        case .deviceType(let reason):
            return reason.localizedDescription
        case .monetization(let reason):
            return reason.localizedDescription
        case .rule(let reason):
            return reason.localizedDescription
        case .subscription(let reason):
            return reason.localizedDescription
        case .machineLearning(let reason):
            return reason.localizedDescription
        case .deviceManagement(let reason):
            return reason.localizedDescription
        case .websocket(let reason):
            return reason.localizedDescription
        }
    }
}

extension ArtikError.RateLimitReason {
    var localizedDescription: String {
        switch self {
        case .rateLimitMinuteReached:
            return "Rate Limit Minute Reached."
        case .rateLimitDailyReached:
            return "Rate Limit Daily Reached."
        case .organizationQuotaReached:
            return "Organization Quota Reached."
        case .deviceQuotaReached(let did, let quota):
            var description = "Device Quota of \"\(quota)\" reached"
            if let did = did {
                description += " for did: \(did)"
            } else {
                description += "."
            }
            return description
        }
    }
}

extension ArtikError.ArtikCloudSwiftSettingsReason {
    var localizedDescription: String {
        switch self {
        case .noUserToken:
            return "No User Token found in ArtikCloudSwiftSettings."
        case .noApplicationToken:
            return "No Application Token found in ArtikCloudSwiftSettings."
        case .noRedirectURI:
            return "No Redirect URI found in ArtikCloudSwiftSettings."
        case .noClientID:
            return "No Client ID found in ArtikCloudSwiftSettings."
        case .noClientSecret:
            return "No Client Secret found in ArtikCloudSwiftSettings."
        case .clientIdAndClientSecretCouldNotBeEncoded:
            return "The Client ID & Client Secret found in ArtikCloudSwiftSettings could not be encoded."
        }
    }
}

extension ArtikError.ApplicationCallbackReason {
    var localizedDescription: String {
        switch self {
        case .missingDeviceCode:
            return "The callback is missing an expected Device Code."
        case .containsInvalidToken:
            return "The callback contains an invalid or misformated Token."
        case .doesNotMatchRedirectURI:
            return "The callback received did not match the redirect URI requested."
        }
    }
}

extension ArtikError.AuthorizationCodeAuthenticationReason {
    var localizedDescription: String {
        switch self {
        case .codeVerifierNotFound:
            return "No code verifier found. Did you mean to use PKCE?"
        case .failedToHashVerifier:
            return "Failed to hash code_verifier."
        case .failedToGenerateVerifier:
            return "Failed to generate secure random bytes for verifier."
        }
    }
}

extension ArtikError.LimitedInputAuthenticationReason {
    var localizedDescription: String {
        switch self {
        case .accessDenied:
            return "Request Denied by the User."
        case .pending:
            return "Waiting for user code."
        case .slowDown:
            return "Polling too frequently."
        case .expiredCode:
            return "Device or User code expired."
        case .missingDeviceCode:
            return "The LimitedInputCode instance provided is missing a device code."
        }
    }
}

extension ArtikError.TokenReason {
    var localizedDescription: String {
        switch self {
        case .invalidToken:
            return "The Token is invalid."
        case .noRefreshToken:
            return "The Token does not contain a refresh token."
        case .failedToRefresh:
            return "Failed to refresh the Token."
        }
    }
}

extension ArtikError.MissingValueReason {
    var localizedDescription: String {
        let main = "Method/Instance missing: "
        switch self {
        case .noID:
            return main + "ID"
        case .noName:
            return main + "Name"
        case .noAvailability:
            return main + "Availability"
        case .noSdid:
            return main + "SDID"
        case .noStartDate:
            return main + "Start Date"
        case .noEndDate:
            return main + "End Date"
        case .noField:
            return main + "Field"
        case .noInterval:
            return main + "Interval"
        case .noRule:
            return main + "Rule"
        case .noExpiresIn:
            return main + "Expires In"
        case .noEmailOrInvalid:
            return main + "Email (possibly invalid)"
        case .noOffsetCursor:
            return main + "Offset Cursor for Pagination"
        case .noActions:
            return main + "Actions"
        }
    }
}

extension ArtikError.JSONReason {
    var localizedDescription: String {
        switch self {
        case .unexpectedFormat:
            return "The JSON received did not have the formatting/structure expected."
        case .invalidItem:
            return "The JSON contains an invalid item."
        case .countAndContentDoNotMatch:
            return "The JSON's count property does not match the count of its data property."
        }
    }
}

extension ArtikError.URLReason {
    var localizedDescription: String {
        switch self {
        case .failedToInit:
            return "There was a problem initialiazing the URL."
        case .failedToEncode:
            return "There was a problem encoding the URL."
        case .failedToParse:
            return "There was a problem parsing the URL."
        }
    }
}

extension ArtikError.DeviceTypeReason {
    var localizedDescription: String {
        switch self {
        case .approvedListFailedToEncode:
            return "The Approved List provided failed to be encoded to Data. Invalid List?"
        }
    }
}

extension ArtikError.MonetizationReason {
    var localizedDescription: String {
        switch self {
        case .missingUpgradeStatus:
            return "The upgrade status was missing from the callback."
        }
    }
}

extension ArtikError.RuleReason {
    var localizedDescription: String {
        switch self {
        case .oneOrMoreActionNotTestable:
            return "One or more actions in this Rule is not testable."
        case .invalidScopeProvided:
            return "The scope provided is invalid for this request."
        }
    }
}

extension ArtikError.SubscriptionReason {
    var localizedDescription: String {
        switch self {
        case .cannotUseBothSdtidAndSdid:
            return "Both SDTID & SDID cannot be used together."
        }
    }
}

extension ArtikError.MachineLearningReason {
    var localizedDescription: String {
        switch self {
        case .invalidPredictIn:
            return "Invalid \"predictIn\", must be greater than 0."
        case .invalidSensitivity:
            return "Invalid \"anomalyDetectionSensitivity\", must be between 0 and 100 (inclusive)."
        }
    }
}

extension ArtikError.DeviceManagementReason {
    var localizedDescription: String {
        switch self {
        case .invalidPmin:
            return "Invalid \"pmin\". Must be between 60 and 3600 (inclusive)."
        case .invalidPmax:
            return "Invalid \"pmax\". Must be between 3600 and 86400 (inclusive)."
        case .invalidTaskExpiresAfter:
            return "Invalid \"taskExpiresAfter\". Must be between 60 and 604800 (inclusive)."
        }
    }
}

extension ArtikError.WebsocketReason {
    var localizedDescription: String {
        switch self {
        case .receivedAckError(let code, let message):
            return "ARTIK Websocket Error Message:\n    Code: \(code)\n    Message: \(message)"
        case .unableToSerializeReceivedData:
            return "The Data received failed to serialize to the desired object. Invalid JSON?"
        case .unableToEncodeMessage:
            return "There was a problem encoding the desired websocket message to JSON."
        case .socketIsNotConnected:
            return "The socket is not connected, which is required to perform the desired action."
        case .tokenRequired:
            return "The socket does not have a token, required to initiate a connection."
        case .responseTimedout:
            return "The socket took too long to reply."
        case .unexpectedResponse:
            return "The socket's response did not contain the expected data for your request."
        case .writeAlreadyOngoing:
            return "There is already a write operation ongoing awaiting a response from the websocket. Please try again after it finishes."
        case .pingTimeout:
            return "ARTIK websocket ping timeout."
        }
    }
}
