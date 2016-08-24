//
// TokenInfo.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


/**  */
public class TokenInfo: JSONEncodable {
    public var clientId: String?
    public var deviceId: String?
    public var expiresIn: Int32?
    public var userId: String?

    public init() {}

    // MARK: JSONEncodable
    func encodeToJSON() -> AnyObject {
        var nillableDictionary = [String:AnyObject?]()
        nillableDictionary["client_id"] = self.clientId
        nillableDictionary["device_id"] = self.deviceId
        nillableDictionary["expires_in"] = self.expiresIn?.encodeToJSON()
        nillableDictionary["user_id"] = self.userId
        let dictionary: [String:AnyObject] = APIHelper.rejectNil(nillableDictionary) ?? [:]
        return dictionary
    }
}