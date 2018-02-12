//
//  ArtikWebsockets.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 1/17/18.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit
import Starscream

@available(watchOS, unavailable)
public protocol ArtikWebsocketDelegate: class {
    
    /// Called when the socket has successfuly established a connection.
    ///
    /// - Parameter socket: The `ArtikWebsocket` which connected.
    func websocketDidConnect(socket: ArtikWebsocket)
    
    /// Called when the socket has been disconnected, indicating if it was due to an error and if it is attempting to reconnect.
    ///
    /// - Parameters:
    ///   - socket: The `ArtikWebsocket` which disconnected.
    ///   - reconnecting: A `Bool` indicating if it is attempting to reconnect.
    ///   - error: The `Error` causing the disconnection, `nil` if not caused by an error.
    func websocketDidDisconnect(socket: ArtikWebsocket, reconnecting: Bool, error: Error?)
    
    /// Called when an error occured while performing an operation.
    ///
    /// - Parameters:
    ///   - socket: The `ArtikWebsocket` where an error occured.
    ///   - error: The `Error` which occured.
    func websocketEncounteredError(socket: ArtikWebsocket, error: Error)
}

@available(watchOS, unavailable)
open class ArtikWebsocket: WebSocketDelegate {
    fileprivate let pingInterval: Int = 30
    fileprivate var websocket: WebSocket!
    fileprivate var attempts: Int = 0
    fileprivate var reconnect = true
    fileprivate var pingUUID: UUID? = nil
    fileprivate var token: Token? {
        didSet {
            didSetToken()
        }
    }
    
    public var name: String {
        return ""
    }
    public var endpoint: String {
        return ""
    }
    public var url: URL {
        return URL(string: ArtikCloudSwiftSettings.websocketPath + endpoint)!
    }
    public var isConnected: Bool {
        return websocket.isConnected
    }
    
    public weak var delegate: ArtikWebsocketDelegate?
    public var maximumAttemps: Int = 5
    
    fileprivate init() {
        commonInit()
    }
    
    deinit {
        disconnect()
    }
    
    // Public
    
    /// Connect to the WebSocket server on a background thread, using the provided `Token` or by getting it from `ArtikCloudSwiftSettings`.
    ///
    /// - Parameter token: (Optional) A specific `Token` to use for this socket.
    public func connect(token: Token? = nil) {
        trace()
        guard !isConnected else {
            return
        }
        
        if let _ = token {
            self.token = token
            websocket.connect()
        } else {
            APIHelpers.getAuthToken(preference: ArtikCloudSwiftSettings.preferredTokenForWebsockets).then { token -> Void in
                self.token = token
                self.websocket.connect()
            }.catch { error -> Void in
                self.delegate?.websocketEncounteredError(socket: self, error: error)
            }
        }
    }
    
    /// Connect to the WebSocket server on a background thread async after the provided deadline.
    ///
    /// - Parameter deadline: A `Double` representing the deadline from now to execute `.connect()`.
    /// - Parameter token: (Optional) A specific `Token` to use for this socket.
    public func connect(deadline: Double, token: Token? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + deadline) {
            self.connect(token: token)
        }
    }
    
    /// Disconnect from the server.
    public func disconnect() {
        trace()
        reconnect = false
        pingUUID = nil
        
        guard isConnected else {
            return
        }
        websocket.disconnect()
    }
    
    // WebSocketDelegate
    
    public func websocketDidConnect(socket: WebSocketClient) {
        trace()
        attempts = 0
        reconnect = true
        pingUUID = nil
        handlePing()
        delegate?.websocketDidConnect(socket: self)
    }
    
    public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        trace()
        if reconnect {
            var reconnect = attempts <= maximumAttemps
            if let error = error {
                reconnect = reconnect && shouldSocketAttemptToReconnect(error as NSError)
            }
            
            if reconnect {
                attempts += 1
                connect(deadline: 0.5 * pow(2, Double(attempts > 1 ? attempts - 1 : 0)))
                delegate?.websocketDidDisconnect(socket: self, reconnecting: true, error: error)
                return
            }
        }
        delegate?.websocketDidDisconnect(socket: self, reconnecting: false, error: error)
    }
    
    public func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        trace()
        do {
            if let data = text.data(using: .utf8), let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                if let type = json["type"] as? String, type == "ping" {
                    handlePing()
                    return
                } else if let error = json["error"] as? [String:Any], let code = error["code"] as? Int, let message = error["message"] as? String {
                    websocketDidReceiveError(socket: socket, error: ArtikError.websocket(reason: .receivedAckError(code: code, message: message)))
                    return
                }
                websocketDidReceiveJSON(socket: socket, json: json)
            } else {
                delegate?.websocketEncounteredError(socket: self, error: ArtikError.websocket(reason: .unableToSerializeReceivedData))
            }
        } catch {
            delegate?.websocketEncounteredError(socket: self, error: error)
        }
    }
    
    public func websocketDidReceiveData(socket: WebSocketClient, data: Data) {}
    
    // Overridable Methods
    
    fileprivate func websocketDidReceiveJSON(socket: WebSocketClient, json: [String:Any]) {
        trace()
    }
    
    fileprivate func websocketDidReceiveError(socket: WebSocketClient, error: ArtikError) {
        trace()
        delegate?.websocketEncounteredError(socket: self, error: error)
    }
    
    // Private
    
    fileprivate func commonInit() {
        websocket = WebSocket(url: url)
        websocket.delegate = self
        websocket.enabledSSLCipherSuites = [TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256]
    }
    
    fileprivate func didSetToken() {
        if let token = token {
            websocket.request.setValue(token.getHeaderValue(), forHTTPHeaderField: APIHelpers.authorizationHeaderKey)
        }
    }
    
    fileprivate func trace(function: NSString = #function) {
        ArtikCloudSwiftSettings.trace?("ARTIK Cloud Websocket:\n    \(name): \(function)")
    }
    
    fileprivate func handlePing() {
        trace()
        let current = UUID()
        pingUUID = current
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(pingInterval + 10)) { [weak self, current] in
            guard let _self = self else {
                return
            }
            if _self.isConnected && _self.pingUUID == current {
                _self.commonInit()
                _self.websocketDidDisconnect(socket: _self.websocket, error: ArtikError.websocket(reason: .pingTimeout))
            }
        }
    }
    
    fileprivate func shouldSocketAttemptToReconnect(_ error: NSError) -> Bool {
        if error.domain == WebSocket.ErrorDomain {
            switch error.code {
            case 401:
                return false
            case 403:
                return false
            case 429:
                return false
            default:
                break
            }
        }
        return true
    }
    
}

@available(watchOS, unavailable)
public protocol EventsWebsocketDelegate: ArtikWebsocketDelegate {
    
    /// Called when the socket receives an event.
    ///
    /// - Parameters:
    ///   - socket: The `EventsWebsocket` which received the event.
    ///   - event: The `EventsWebsocket.EventType` received.
    ///   - uid: (Optional) The User ID involved in the event.
    ///   - aid: (Optional) The Application ID from which the event comes from.
    ///   - did: (Optional) The Device ID involved in the event.
    ///   - dtid: (Optional) The Device Type ID involved in the event.
    ///   - ts: The `ArtikTimestamp` at which the event occured.
    func websocketDidReceiveEvent(socket: EventsWebsocket, event: EventsWebsocket.EventType, uid: String?, aid: String?, did: String?, dtid: String?, ts: ArtikTimestamp)
}

@available(watchOS, unavailable)
open class EventsWebsocket: ArtikWebsocket {
    
    public enum EventType: String {
        case new = "device.new"
        case connected = "device.connected"
        case updated = "device.updated"
        case disconnected = "device.disconnected"
        case deleted = "device.deleted"
        case online = "device.status.online"
        case offline = "device.status.offline"
        case userProfileUpdated = "user.profile.updated"
    }
    
    override public var name: String {
        return "Events"
    }
    override public var endpoint: String {
        return "/events"
    }
    override public var url: URL {
        var params = [String]()
        if let uid = uid {
            params.append("uid=\(uid)")
        }
        if let dids = dids, dids.count > 0 {
            if dids.count == 1, let first = dids.first {
                params.append("did=\(first)")
            } else {
                params.append("dids=\(dids.joined(separator: ","))")
            }
        }
        if let events = events, events.count > 0 {
            params.append("events=\(events.map { $0.rawValue }.joined(separator: ","))")
        }
        if params.count > 0 {
            return URL(string: ArtikCloudSwiftSettings.websocketPath + endpoint + "?\(params.joined(separator: "&"))")!
        }
        return URL(string: ArtikCloudSwiftSettings.websocketPath + endpoint)!
    }
    
    fileprivate var ignoreEvents = [String:Set<EventType>]()
    public fileprivate(set) var uid: String?
    public fileprivate(set) var dids: [String]?
    public fileprivate(set) var events: [EventType]?
    
    /// Initialize an Events Websocket
    ///
    /// - Parameters:
    ///   - uid: (Optional) User ID of the target stream. If not specified, the uid implied in the access token is assumed.
    ///   - dids: (Optional) Device IDs for which to receive events.
    ///   - events: (Optional) Event names or event names with wildcard (e.g., device.*, user.profile.updated).
    public init(uid: String? = nil, dids: [String]? = nil, events: [EventType]? = nil) {
        self.uid = uid
        self.dids = dids
        self.events = events
        super.init()
    }
    
    // Public Methods
    
    /// Ignore a certain event type for a specific device.
    ///
    /// - Parameters:
    ///   - event: The `EventType` to be ignored.
    ///   - did: The Device's ID.
    public func ignoreEvent(_ event: EventType, forDid did: String) {
        if var ignoreList = ignoreEvents[did] {
            ignoreList.insert(event)
            ignoreEvents[did] = ignoreList
            return
        }
        ignoreEvents[did] = [event]
    }
    
    /// Ignore certain event types for a specific device.
    ///
    /// - Parameters:
    ///   - events: The `Set<EventType>` to be ignored.
    ///   - did: The Device's ID.
    public func ignoreEvents(_ events: Set<EventType>, forDid did: String) {
        if let ignoreList = ignoreEvents[did] {
            ignoreEvents[did] = ignoreList.union(events)
            return
        }
        ignoreEvents[did] = events
    }
    
    /// Stop ignoring a certain event type for a specific device.
    ///
    /// - Parameters:
    ///   - event: The `EventType` to stop ignoring.
    ///   - did: The Device's ID.
    public func stopIgnoringEvent(_ event: EventType, forDid did: String) {
        guard var ignoreList = ignoreEvents[did] else {
            return
        }
        ignoreList.remove(event)
        ignoreEvents[did] = ignoreList.count > 0 ? ignoreList : nil
    }
    
    /// Stop ignoring any event types for a specific device.
    ///
    /// - Parameter did: The Device's ID
    public func stopIgnoringEvents(forDid did: String) {
        _ = ignoreEvents.removeValue(forKey: did)
    }
    
    /// Stop ignoring any event types for any devices.
    public func stopIgnoringEvents() {
        ignoreEvents.removeAll()
    }
    
    /// Get the events ignored for a specific device.
    ///
    /// - Parameter did: The Device's ID.
    /// - Returns: Returns a `Set<EventType>` or nil if nothing is ignored.
    public func getEventsIgnored(forDid did: String) -> Set<EventType>? {
        return ignoreEvents[did]
    }
    
    // Overridable Methods
    
    override fileprivate func websocketDidReceiveJSON(socket: WebSocketClient, json: [String : Any]) {
        super.websocketDidReceiveJSON(socket: socket, json: json)
        if let data = json["data"] as? [String:Any], let eventraw = json["event"] as? String, let event = EventType(rawValue: eventraw), let ts = json["ts"] as? ArtikTimestamp {
            let did = data["did"] as? String
            if let did = did, let ignoreList = ignoreEvents[did], ignoreList.contains(event) {
                return
            }
            (delegate as? EventsWebsocketDelegate)?.websocketDidReceiveEvent(socket: self, event: event, uid: data["uid"] as? String, aid: data["aid"] as? String, did: did, dtid: data["dtid"] as? String, ts: ts)
        } else {
            delegate?.websocketEncounteredError(socket: self, error: ArtikError.json(reason: .unexpectedFormat))
        }
    }
}

@available(watchOS, unavailable)
public protocol LiveWebsocketDelegate: ArtikWebsocketDelegate {
    
    /// Called when the socket receives a message.
    ///
    /// - Parameters:
    ///   - socket: The `LiveWebsocket` which received the message.
    ///   - mid: The message's ID.
    ///   - data: The message's data.
    ///   - sdid: The Source Device ID of the message.
    ///   - sdtid: (Optional) The Source Device Type ID of the message.
    ///   - uid: (Optional) The User ID related to the message.
    ///   - ts: The `ArtikTimestamp` at which the message was received.
    func websocketDidReceiveMessage(socket: LiveWebsocket, mid: String, data: [String:Any], sdid: String, sdtid: String?, uid: String?, ts: ArtikTimestamp)
}

@available(watchOS, unavailable)
open class LiveWebsocket: ArtikWebsocket {
    override public var name: String {
        return "Live"
    }
    override public var endpoint: String {
        return "/live"
    }
    override public var url: URL {
        var string = ArtikCloudSwiftSettings.websocketPath + endpoint + "?includeSharedDevices=\(includeSharedDevices)"
        if let uid = uid {
            string += "&uid=\(uid)"
        }
        return URL(string: string)!
    }
    
    fileprivate var ignoreDids = Set<String>()
    public fileprivate(set) var uid: String?
    public fileprivate(set) var includeSharedDevices: Bool
    
    /// Initialize a Live (Firehose) Websocket
    ///
    /// - Parameter uid: (Optional) User ID of the target stream.
    /// - Parameter includeSharedDevices: (Optional) Include shared devices (default: `false`). Only applies when connecting with `UserToken` or providing a uid.
    public init(uid: String? = nil, includeSharedDevices: Bool = false) {
        self.uid = uid
        self.includeSharedDevices = includeSharedDevices
        super.init()
    }
    
    // Public Methods
    
    /// Start ignoring messages from a specific device.
    ///
    /// - Parameter did: The Device's ID.
    public func ignore(did: String) {
        ignoreDids.insert(did)
    }
    
    /// Stop ignoring messages from a specific device.
    ///
    /// - Parameter did: The Device's ID.
    public func stopIgnoring(did: String) {
        _ = ignoreDids.remove(did)
    }
    
    /// Stop ignoring messages of any device previously ignored.
    public func stopIgnoring() {
        ignoreDids.removeAll()
    }
    
    /// Used to know if a specific device's messages are currently being ignored.
    ///
    /// - Parameter did: The Device' ID.
    /// - Returns: Returns a `Bool` indicating if the device is currently being ignored.
    public func isIgnoring(did: String) -> Bool {
        return ignoreDids.contains(did)
    }
    
    // Overridable Methods
    
    override fileprivate func websocketDidReceiveJSON(socket: WebSocketClient, json: [String : Any]) {
        super.websocketDidReceiveJSON(socket: socket, json: json)
        if let sdid = json["sdid"] as? String, let data = json["data"] as? [String:Any], let ts = json["ts"] as? ArtikTimestamp, let mid = json["mid"] as? String {
            guard !ignoreDids.contains(sdid) else {
                return
            }
            (delegate as? LiveWebsocketDelegate)?.websocketDidReceiveMessage(socket: self, mid: mid, data: data, sdid: sdid, sdtid: json["sdtid"] as? String, uid: json["uid"] as? String, ts: ts)
        } else {
            delegate?.websocketEncounteredError(socket: self, error: ArtikError.json(reason: .unexpectedFormat))
        }
    }
    
}

@available(watchOS, unavailable)
public protocol DeviceWebsocketDelegate: ArtikWebsocketDelegate {
    
    /// Called when the socket receives an action for a device.
    ///
    /// - Parameters:
    ///   - socket: The `DeviceWebsocket` which received the action.
    ///   - mid: The Action's ID.
    ///   - data: The Action's data.
    ///   - ddid: The Action's Destination Device ID.
    func websocketDidReceiveAction(socket: DeviceWebsocket, mid: String, data: [String:Any], ddid: String)
}

@available(watchOS, unavailable)
open class DeviceWebsocket: ArtikWebsocket {
    
    public enum MessageType: String {
        case register = "register"
        case unregister = "unregister"
        case list = "list"
    }
    
    override public var name: String {
        return "Device"
    }
    override public var endpoint: String {
        return "/websocket"
    }
    override public var url: URL {
        return URL(string: ArtikCloudSwiftSettings.websocketPath + endpoint + "?ack=\(ack)")!
    }
    
    fileprivate var listPromise: (promise: Promise<[String]>, fulfill: ([String]) -> Void, reject: (Error) -> Void)?
    fileprivate var registrationPromise: (promise: Promise<Void>, fulfill: () -> Void, reject: (Error) -> Void)?
    fileprivate var messagePromise: (promise: Promise<String?>, fulfill: (String?) -> Void, reject: (Error) -> Void)?
    public fileprivate(set) var ack: Bool
    var isResponsePending: Bool {
        return registrationPromise != nil || listPromise != nil || messagePromise != nil
    }
    
    /// Initialize a Device Websocket.
    ///
    /// - Parameter ack: (Optional) WebSocket returns ACK messages for each message sent by client. If not specified, defaults to `false`.
    public init(ack: Bool = false) {
        self.ack = ack
        super.init()
    }
    
    override public func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        super.websocketDidDisconnect(socket: socket, error: error)
        listPromise?.reject(ArtikError.websocket(reason: .responseTimedout))
        listPromise = nil
        
        registrationPromise?.reject(ArtikError.websocket(reason: .responseTimedout))
        registrationPromise = nil
        
        messagePromise?.reject(ArtikError.websocket(reason: .responseTimedout))
        messagePromise = nil
    }
    
    // Public
    
    /// Connect to the WebSocket on a background thread.
    ///
    /// - Parameter token: (Optional) A specific `Token` to use when registering devices.
    public override func connect(token: Token?) {
        super.connect(token: token)
    }
    
    /// Connect to the WebSocket on a background thread async after the provided deadline.
    ///
    /// - Parameter deadline: A `Double` representing the deadline from now to execute `.connect()`.
    /// - Parameter token: (Optional) A specific `Token` to use when registering devices.
    public override func connect(deadline: Double, token: Token?) {
        super.connect(deadline: deadline, token: token)
    }
    
    /// Register a device with the socket.
    ///
    /// - Parameters:
    ///   - did: The Device's ID.
    ///   - token: (Optional) A specific `Token` to use. If ommited, the `Token` provided when connecting will be used, or one from `ArtikCloudSwiftSettings`.
    /// - Returns: A `Promise<Void>`. If `ack` is `True`, waits for the response to fulfill.
    public func register(did: String, token: Token? = nil) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        trace()
        if isResponsePending {
            promise.reject(ArtikError.websocket(reason: .writeAlreadyOngoing))
            return promise.promise
        } else if ack {
            registrationPromise = promise
        }
        guard isConnected else {
            promise.reject(ArtikError.websocket(reason: .socketIsNotConnected))
            return promise.promise
        }
        
        guard let token = token ?? self.token else {
            promise.reject(ArtikError.websocket(reason: .tokenRequired))
            return promise.promise
        }
        
        var parameters: [String:Any] = [
            "sdid": did,
            APIHelpers.authorizationHeaderKey: token.getHeaderValue(),
            "type": MessageType.register.rawValue
        ]
        if let cid = ArtikCloudSwiftSettings.clientID {
            parameters["cid"] = cid
        }
        do {
            let completion: (() -> ())? = ack ? nil : {
                promise.fulfill(())
            }
            websocket.write(string: try toJson(parameters), completion: completion)
        } catch {
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Unregister a device from the socket.
    ///
    /// - Parameter did: The Device's ID.
    /// - Returns: A `Promise<Void>`. If `ack` is `True`, waits for the response to fulfill.
    public func unregister(did: String) -> Promise<Void> {
        let promise = Promise<Void>.pending()
        trace()
        if isResponsePending {
            promise.reject(ArtikError.websocket(reason: .writeAlreadyOngoing))
            return promise.promise
        } else if ack {
            registrationPromise = promise
        }
        guard isConnected else {
            promise.reject(ArtikError.websocket(reason: .socketIsNotConnected))
            return promise.promise
        }
        
        var parameters: [String:Any] = [
            "sdid": did,
            "type": MessageType.unregister.rawValue
        ]
        if let cid = ArtikCloudSwiftSettings.clientID {
            parameters["cid"] = cid
        }
        do {
            let completion: (() -> ())? = ack ? nil : {
                promise.fulfill(())
            }
            websocket.write(string: try toJson(parameters), completion: completion)
        } catch {
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Get a list of devices currently registered on the socket.
    ///
    /// - Returns: A `Promise<[String]>` containing the devices' IDs.
    public func list() -> Promise<[String]> {
        let promise = Promise<[String]>.pending()
        trace()
        if isResponsePending {
            promise.reject(ArtikError.websocket(reason: .writeAlreadyOngoing))
            return promise.promise
        } else if ack {
            listPromise = promise
        }
        guard isConnected else {
            promise.reject(ArtikError.websocket(reason: .socketIsNotConnected))
            return promise.promise
        }
        
        var parameters: [String:Any] = ["type": MessageType.list.rawValue]
        if let cid = ArtikCloudSwiftSettings.clientID {
            parameters["cid"] = cid
        }
        do {
            websocket.write(string: try toJson(parameters))
        } catch {
            promise.reject(error)
        }
        return promise.promise
    }
    
    /// Send a message from a device through the socket.
    ///
    /// - Parameters:
    ///   - sdid: The Source Device's ID.
    ///   - data: The Message's data.
    ///   - ts: The Message timestamp. Must be a valid time: past time, present or future up to the current server timestamp grace period. Current time if omitted.
    /// - Returns: A `Promise<String?>` representing the resulting message's id. If `ack` is `false`, fulfills with `nil`.
    public func sendMessage(sdid: String, data: [String:Any], ts: ArtikTimestamp? = nil) -> Promise<String?> {
        return sendMessage(ddid: nil, sdid: sdid, data: data, ts: ts)
    }
    
    /// Send an action to a device through the socket.
    ///
    /// - Parameters:
    ///   - ddid: The Destination Device's ID.
    ///   - sdid: (Optional) The Source Device's ID.
    ///   - data: The Action's data.
    ///   - ts: The Action timestamp. Must be a valid time: past time, present or future up to the current server timestamp grace period. Current time if omitted.
    /// - Returns: A `Promise<String?>` representing the resulting message's id. If `ack` is `false`, fulfills with `nil`.
    public func sendAction(ddid: String, sdid: String? = nil, data: [String:Any], ts: ArtikTimestamp? = nil) -> Promise<String?> {
        return sendMessage(ddid: ddid, sdid: sdid, data: data, ts: ts)
    }
    
    // Overridable Methods
    
    override func websocketDidReceiveJSON(socket: WebSocketClient, json: [String : Any]) {
        super.websocketDidReceiveJSON(socket: socket, json: json)
        if ack {
            if let promise = registrationPromise {
                if let data = json["data"] as? [String:Any], let code = data["code"] as? Int, code == 200, let message = data["message"] as? String, message == "OK" {
                    promise.fulfill()
                    registrationPromise = nil
                    return
                } else {
                    promise.reject(ArtikError.websocket(reason: .unexpectedResponse))
                    registrationPromise = nil
                }
            }
            if let promise = messagePromise {
                if let data = json["data"] as? [String:Any], let mid = data["mid"] as? String {
                    promise.fulfill(mid)
                    messagePromise = nil
                    return
                } else {
                    promise.reject(ArtikError.websocket(reason: .unexpectedResponse))
                    messagePromise = nil
                }
            }
        } else {
            registrationPromise?.fulfill()
            registrationPromise = nil
            
            messagePromise?.fulfill(nil)
            messagePromise = nil
        }
        if let promise = listPromise {
            if let data = json["data"] as? [String:Any], let code = data["code"] as? Int, code == 200, let message = data["message"] as? [String] {
                promise.fulfill(message)
                listPromise = nil
                return
            } else {
                promise.reject(ArtikError.websocket(reason: .unexpectedResponse))
                listPromise = nil
            }
        }
        if let ddid = json["ddid"] as? String, let mid = json["mid"] as? String, let data = json["data"] as? [String:Any] {
            (delegate as? DeviceWebsocketDelegate)?.websocketDidReceiveAction(socket: self, mid: mid, data: data, ddid: ddid)
        }
    }
    
    override func websocketDidReceiveError(socket: WebSocketClient, error: ArtikError) {
        if let promise = registrationPromise {
            promise.reject(error)
            registrationPromise = nil
        } else if let promise = messagePromise {
            promise.reject(error)
            messagePromise = nil
        } else if let promise = listPromise {
            promise.reject(error)
            listPromise = nil
        } else {
            super.websocketDidReceiveError(socket: socket, error: error)
        }
    }
    
    // Private Methods
    
    override fileprivate func didSetToken() {
        // Do nothing
    }
    
    fileprivate func toJson(_ data: [String:Any]) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
        if let result = String(data: jsonData, encoding: .utf8) {
            return result
        }
        throw ArtikError.websocket(reason: .unableToEncodeMessage)
    }
    
    fileprivate func sendMessage(ddid: String?, sdid: String?, data: [String:Any], ts: ArtikTimestamp? = nil) -> Promise<String?> {
        let promise = Promise<String?>.pending()
        trace()
        if isResponsePending {
            promise.reject(ArtikError.websocket(reason: .writeAlreadyOngoing))
            return promise.promise
        } else if ack {
            messagePromise = promise
        }
        guard isConnected else {
            promise.reject(ArtikError.websocket(reason: .socketIsNotConnected))
            return promise.promise
        }
        
        var parameters: [String:Any] = [
            "data": data
        ]
        if let ddid = ddid {
            parameters["ddid"] = ddid
        }
        if let sdid = sdid {
            parameters["sdid"] = sdid
        }
        if let ts = ts {
            parameters["ts"] = ts
        }
        if let cid = ArtikCloudSwiftSettings.clientID {
            parameters["cid"] = cid
        }
        
        do {
            let completion: (() -> ())? = ack ? nil : {
                promise.fulfill(nil)
            }
            websocket.write(string: try toJson(parameters), completion: completion)
        } catch {
            promise.reject(error)
        }
        return promise.promise
    }
}
