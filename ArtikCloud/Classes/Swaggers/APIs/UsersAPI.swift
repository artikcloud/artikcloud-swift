//
// UsersAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Alamofire
import PromiseKit



public class UsersAPI: APIBase {
    /**
     Create User Application Properties
     
     - parameter userId: (path) User Id 
     - parameter properties: (body) Properties to be updated 
     - parameter aid: (query) Application ID (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func createUserProperties(userId userId: String, properties: AppProperties, aid: String? = nil, completion: ((data: PropertiesEnvelope?, error: ErrorType?) -> Void)) {
        createUserPropertiesWithRequestBuilder(userId: userId, properties: properties, aid: aid).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Create User Application Properties
     
     - parameter userId: (path) User Id 
     - parameter properties: (body) Properties to be updated 
     - parameter aid: (query) Application ID (optional)
     - returns: Promise<PropertiesEnvelope>
     */
    public class func createUserProperties(userId userId: String, properties: AppProperties, aid: String? = nil) -> Promise<PropertiesEnvelope> {
        let deferred = Promise<PropertiesEnvelope>.pendingPromise()
        createUserProperties(userId: userId, properties: properties, aid: aid) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Create User Application Properties
     - POST /users/{userId}/properties
     - Create application properties for a user
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "data" : {
    "uid" : "aeiou",
    "aid" : "aeiou",
    "properties" : "aeiou"
  }
}}]
     
     - parameter userId: (path) User Id 
     - parameter properties: (body) Properties to be updated 
     - parameter aid: (query) Application ID (optional)

     - returns: RequestBuilder<PropertiesEnvelope> 
     */
    public class func createUserPropertiesWithRequestBuilder(userId userId: String, properties: AppProperties, aid: String? = nil) -> RequestBuilder<PropertiesEnvelope> {
        var path = "/users/{userId}/properties"
        path = path.stringByReplacingOccurrencesOfString("{userId}", withString: "\(userId)", options: .LiteralSearch, range: nil)
        let URLString = ArtikCloudAPI.basePath + path
        let parameters = properties.encodeToJSON() as? [String:AnyObject]
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<PropertiesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "POST", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Delete User Application Properties
     
     - parameter userId: (path) User Id 
     - parameter aid: (query) Application ID (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func deleteUserProperties(userId userId: String, aid: String? = nil, completion: ((data: PropertiesEnvelope?, error: ErrorType?) -> Void)) {
        deleteUserPropertiesWithRequestBuilder(userId: userId, aid: aid).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Delete User Application Properties
     
     - parameter userId: (path) User Id 
     - parameter aid: (query) Application ID (optional)
     - returns: Promise<PropertiesEnvelope>
     */
    public class func deleteUserProperties(userId userId: String, aid: String? = nil) -> Promise<PropertiesEnvelope> {
        let deferred = Promise<PropertiesEnvelope>.pendingPromise()
        deleteUserProperties(userId: userId, aid: aid) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Delete User Application Properties
     - DELETE /users/{userId}/properties
     - Deletes a user's application properties
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "data" : {
    "uid" : "aeiou",
    "aid" : "aeiou",
    "properties" : "aeiou"
  }
}}]
     
     - parameter userId: (path) User Id 
     - parameter aid: (query) Application ID (optional)

     - returns: RequestBuilder<PropertiesEnvelope> 
     */
    public class func deleteUserPropertiesWithRequestBuilder(userId userId: String, aid: String? = nil) -> RequestBuilder<PropertiesEnvelope> {
        var path = "/users/{userId}/properties"
        path = path.stringByReplacingOccurrencesOfString("{userId}", withString: "\(userId)", options: .LiteralSearch, range: nil)
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "aid": aid
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<PropertiesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "DELETE", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get Current User Profile
     
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getSelf(completion: ((data: UserEnvelope?, error: ErrorType?) -> Void)) {
        getSelfWithRequestBuilder().execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get Current User Profile
     
     - returns: Promise<UserEnvelope>
     */
    public class func getSelf() -> Promise<UserEnvelope> {
        let deferred = Promise<UserEnvelope>.pendingPromise()
        getSelf() { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get Current User Profile
     - GET /users/self
     - Get's the current user's profile
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "data" : {
    "saIdentity" : "aeiou",
    "modifiedOn" : 123456789,
    "name" : "aeiou",
    "fullName" : "aeiou",
    "id" : "aeiou",
    "createdOn" : 123456789,
    "email" : "aeiou"
  }
}}]

     - returns: RequestBuilder<UserEnvelope> 
     */
    public class func getSelfWithRequestBuilder() -> RequestBuilder<UserEnvelope> {
        let path = "/users/self"
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [:]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<UserEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: true)
    }

    /**
     Get User Device Types
     
     - parameter userId: (path) User ID. 
     - parameter offset: (query) Offset for pagination. (optional)
     - parameter count: (query) Desired count of items in the result set (optional)
     - parameter includeShared: (query) Optional. Boolean (true/false) - If false, only return the user&#39;s device types. If true, also return device types shared by other users. (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getUserDeviceTypes(userId userId: String, offset: Int32? = nil, count: Int32? = nil, includeShared: Bool? = nil, completion: ((data: DeviceTypesEnvelope?, error: ErrorType?) -> Void)) {
        getUserDeviceTypesWithRequestBuilder(userId: userId, offset: offset, count: count, includeShared: includeShared).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get User Device Types
     
     - parameter userId: (path) User ID. 
     - parameter offset: (query) Offset for pagination. (optional)
     - parameter count: (query) Desired count of items in the result set (optional)
     - parameter includeShared: (query) Optional. Boolean (true/false) - If false, only return the user&#39;s device types. If true, also return device types shared by other users. (optional)
     - returns: Promise<DeviceTypesEnvelope>
     */
    public class func getUserDeviceTypes(userId userId: String, offset: Int32? = nil, count: Int32? = nil, includeShared: Bool? = nil) -> Promise<DeviceTypesEnvelope> {
        let deferred = Promise<DeviceTypesEnvelope>.pendingPromise()
        getUserDeviceTypes(userId: userId, offset: offset, count: count, includeShared: includeShared) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get User Device Types
     - GET /users/{userId}/devicetypes
     - Retrieve User's Device Types
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "total" : 123,
  "offset" : 123,
  "data" : {
    "deviceTypes" : [ {
      "hasCloudConnector" : true,
      "issuerDn" : "aeiou",
      "description" : "aeiou",
      "oid" : "aeiou",
      "published" : true,
      "rsp" : true,
      "tags" : [ {
        "isCategory" : true,
        "name" : "aeiou"
      } ],
      "vid" : "aeiou",
      "lastUpdated" : 123456789,
      "uid" : "aeiou",
      "approved" : true,
      "uniqueName" : "aeiou",
      "protected" : true,
      "latestVersion" : 123,
      "inStore" : true,
      "name" : "aeiou",
      "id" : "aeiou",
      "ownedByCurrentUser" : true
    } ]
  },
  "count" : 123
}}]
     
     - parameter userId: (path) User ID. 
     - parameter offset: (query) Offset for pagination. (optional)
     - parameter count: (query) Desired count of items in the result set (optional)
     - parameter includeShared: (query) Optional. Boolean (true/false) - If false, only return the user&#39;s device types. If true, also return device types shared by other users. (optional)

     - returns: RequestBuilder<DeviceTypesEnvelope> 
     */
    public class func getUserDeviceTypesWithRequestBuilder(userId userId: String, offset: Int32? = nil, count: Int32? = nil, includeShared: Bool? = nil) -> RequestBuilder<DeviceTypesEnvelope> {
        var path = "/users/{userId}/devicetypes"
        path = path.stringByReplacingOccurrencesOfString("{userId}", withString: "\(userId)", options: .LiteralSearch, range: nil)
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "offset": offset?.encodeToJSON(),
            "count": count?.encodeToJSON(),
            "includeShared": includeShared
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<DeviceTypesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get User Devices
     
     - parameter userId: (path) User ID 
     - parameter offset: (query) Offset for pagination. (optional)
     - parameter count: (query) Desired count of items in the result set (optional)
     - parameter includeProperties: (query) Optional. Boolean (true/false) - If false, only return the user&#39;s device types. If true, also return device types shared by other users. (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getUserDevices(userId userId: String, offset: Int32? = nil, count: Int32? = nil, includeProperties: Bool? = nil, completion: ((data: DevicesEnvelope?, error: ErrorType?) -> Void)) {
        getUserDevicesWithRequestBuilder(userId: userId, offset: offset, count: count, includeProperties: includeProperties).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get User Devices
     
     - parameter userId: (path) User ID 
     - parameter offset: (query) Offset for pagination. (optional)
     - parameter count: (query) Desired count of items in the result set (optional)
     - parameter includeProperties: (query) Optional. Boolean (true/false) - If false, only return the user&#39;s device types. If true, also return device types shared by other users. (optional)
     - returns: Promise<DevicesEnvelope>
     */
    public class func getUserDevices(userId userId: String, offset: Int32? = nil, count: Int32? = nil, includeProperties: Bool? = nil) -> Promise<DevicesEnvelope> {
        let deferred = Promise<DevicesEnvelope>.pendingPromise()
        getUserDevices(userId: userId, offset: offset, count: count, includeProperties: includeProperties) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get User Devices
     - GET /users/{userId}/devices
     - Retrieve User's Devices
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "total" : 123,
  "offset" : 123,
  "data" : {
    "devices" : [ {
      "eid" : "aeiou",
      "dtid" : "aeiou",
      "manifestVersion" : 123,
      "certificateInfo" : "aeiou",
      "createdOn" : 123456789,
      "connected" : true,
      "uid" : "aeiou",
      "manifestVersionPolicy" : "aeiou",
      "name" : "aeiou",
      "needProviderAuth" : true,
      "certificateSignature" : "aeiou",
      "id" : "aeiou",
      "providerCredentials" : {
        "key" : "{}"
      },
      "properties" : {
        "key" : "{}"
      }
    } ]
  },
  "count" : 123
}}]
     
     - parameter userId: (path) User ID 
     - parameter offset: (query) Offset for pagination. (optional)
     - parameter count: (query) Desired count of items in the result set (optional)
     - parameter includeProperties: (query) Optional. Boolean (true/false) - If false, only return the user&#39;s device types. If true, also return device types shared by other users. (optional)

     - returns: RequestBuilder<DevicesEnvelope> 
     */
    public class func getUserDevicesWithRequestBuilder(userId userId: String, offset: Int32? = nil, count: Int32? = nil, includeProperties: Bool? = nil) -> RequestBuilder<DevicesEnvelope> {
        var path = "/users/{userId}/devices"
        path = path.stringByReplacingOccurrencesOfString("{userId}", withString: "\(userId)", options: .LiteralSearch, range: nil)
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "offset": offset?.encodeToJSON(),
            "count": count?.encodeToJSON(),
            "includeProperties": includeProperties
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<DevicesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get User application properties
     
     - parameter userId: (path) User Id 
     - parameter aid: (query) Application ID (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getUserProperties(userId userId: String, aid: String? = nil, completion: ((data: PropertiesEnvelope?, error: ErrorType?) -> Void)) {
        getUserPropertiesWithRequestBuilder(userId: userId, aid: aid).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get User application properties
     
     - parameter userId: (path) User Id 
     - parameter aid: (query) Application ID (optional)
     - returns: Promise<PropertiesEnvelope>
     */
    public class func getUserProperties(userId userId: String, aid: String? = nil) -> Promise<PropertiesEnvelope> {
        let deferred = Promise<PropertiesEnvelope>.pendingPromise()
        getUserProperties(userId: userId, aid: aid) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get User application properties
     - GET /users/{userId}/properties
     - Get application properties of a user
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "data" : {
    "uid" : "aeiou",
    "aid" : "aeiou",
    "properties" : "aeiou"
  }
}}]
     
     - parameter userId: (path) User Id 
     - parameter aid: (query) Application ID (optional)

     - returns: RequestBuilder<PropertiesEnvelope> 
     */
    public class func getUserPropertiesWithRequestBuilder(userId userId: String, aid: String? = nil) -> RequestBuilder<PropertiesEnvelope> {
        var path = "/users/{userId}/properties"
        path = path.stringByReplacingOccurrencesOfString("{userId}", withString: "\(userId)", options: .LiteralSearch, range: nil)
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "aid": aid
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<PropertiesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get User Rules
     
     - parameter userId: (path) User ID. 
     - parameter excludeDisabled: (query) Exclude disabled rules in the result. (optional)
     - parameter count: (query) Desired count of items in the result set. (optional)
     - parameter offset: (query) Offset for pagination. (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getUserRules(userId userId: String, excludeDisabled: Bool? = nil, count: Int32? = nil, offset: Int32? = nil, completion: ((data: RulesEnvelope?, error: ErrorType?) -> Void)) {
        getUserRulesWithRequestBuilder(userId: userId, excludeDisabled: excludeDisabled, count: count, offset: offset).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get User Rules
     
     - parameter userId: (path) User ID. 
     - parameter excludeDisabled: (query) Exclude disabled rules in the result. (optional)
     - parameter count: (query) Desired count of items in the result set. (optional)
     - parameter offset: (query) Offset for pagination. (optional)
     - returns: Promise<RulesEnvelope>
     */
    public class func getUserRules(userId userId: String, excludeDisabled: Bool? = nil, count: Int32? = nil, offset: Int32? = nil) -> Promise<RulesEnvelope> {
        let deferred = Promise<RulesEnvelope>.pendingPromise()
        getUserRules(userId: userId, excludeDisabled: excludeDisabled, count: count, offset: offset) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get User Rules
     - GET /users/{userId}/rules
     - Retrieve User's Rules
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "total" : 123,
  "data" : [ {
    "languageVersion" : 123,
    "description" : "aeiou",
    "index" : 123,
    "rule" : {
      "key" : "{}"
    },
    "error" : {
      "messageKey" : "aeiou",
      "fieldPath" : {
        "path" : [ {
          "text" : "aeiou"
        } ]
      },
      "messageArgs" : [ "aeiou" ],
      "errorCode" : 123
    },
    "createdOn" : 123456789,
    "enabled" : true,
    "uid" : "aeiou",
    "modifiedOn" : 123456789,
    "name" : "aeiou",
    "warning" : {
      "code" : "aeiou",
      "message" : "aeiou"
    },
    "invalidatedOn" : 123456789,
    "id" : "aeiou",
    "aid" : "aeiou"
  } ],
  "offset" : 123,
  "count" : 123
}}]
     
     - parameter userId: (path) User ID. 
     - parameter excludeDisabled: (query) Exclude disabled rules in the result. (optional)
     - parameter count: (query) Desired count of items in the result set. (optional)
     - parameter offset: (query) Offset for pagination. (optional)

     - returns: RequestBuilder<RulesEnvelope> 
     */
    public class func getUserRulesWithRequestBuilder(userId userId: String, excludeDisabled: Bool? = nil, count: Int32? = nil, offset: Int32? = nil) -> RequestBuilder<RulesEnvelope> {
        var path = "/users/{userId}/rules"
        path = path.stringByReplacingOccurrencesOfString("{userId}", withString: "\(userId)", options: .LiteralSearch, range: nil)
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "excludeDisabled": excludeDisabled,
            "count": count?.encodeToJSON(),
            "offset": offset?.encodeToJSON()
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<RulesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Update User Application Properties
     
     - parameter userId: (path) User Id 
     - parameter properties: (body) Properties to be updated 
     - parameter aid: (query) Application ID (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func updateUserProperties(userId userId: String, properties: AppProperties, aid: String? = nil, completion: ((data: PropertiesEnvelope?, error: ErrorType?) -> Void)) {
        updateUserPropertiesWithRequestBuilder(userId: userId, properties: properties, aid: aid).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Update User Application Properties
     
     - parameter userId: (path) User Id 
     - parameter properties: (body) Properties to be updated 
     - parameter aid: (query) Application ID (optional)
     - returns: Promise<PropertiesEnvelope>
     */
    public class func updateUserProperties(userId userId: String, properties: AppProperties, aid: String? = nil) -> Promise<PropertiesEnvelope> {
        let deferred = Promise<PropertiesEnvelope>.pendingPromise()
        updateUserProperties(userId: userId, properties: properties, aid: aid) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Update User Application Properties
     - PUT /users/{userId}/properties
     - Updates application properties of a user
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "data" : {
    "uid" : "aeiou",
    "aid" : "aeiou",
    "properties" : "aeiou"
  }
}}]
     
     - parameter userId: (path) User Id 
     - parameter properties: (body) Properties to be updated 
     - parameter aid: (query) Application ID (optional)

     - returns: RequestBuilder<PropertiesEnvelope> 
     */
    public class func updateUserPropertiesWithRequestBuilder(userId userId: String, properties: AppProperties, aid: String? = nil) -> RequestBuilder<PropertiesEnvelope> {
        var path = "/users/{userId}/properties"
        path = path.stringByReplacingOccurrencesOfString("{userId}", withString: "\(userId)", options: .LiteralSearch, range: nil)
        let URLString = ArtikCloudAPI.basePath + path
        let parameters = properties.encodeToJSON() as? [String:AnyObject]
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<PropertiesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "PUT", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

}
