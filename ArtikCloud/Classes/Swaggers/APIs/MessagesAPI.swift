//
// MessagesAPI.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Alamofire
import PromiseKit



public class MessagesAPI: APIBase {
    /**
     Get Normalized Message Histogram
     
     - parameter startDate: (query) Timestamp of earliest message (in milliseconds since epoch). 
     - parameter endDate: (query) Timestamp of latest message (in milliseconds since epoch). 
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter field: (query) Message field being queried for building histogram. (optional)
     - parameter interval: (query) Interval of time for building histogram blocks. (Valid values: minute, hour, day, month, year) (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getAggregatesHistogram(startDate startDate: Int64, endDate: Int64, sdid: String? = nil, field: String? = nil, interval: String? = nil, completion: ((data: AggregatesHistogramResponse?, error: ErrorType?) -> Void)) {
        getAggregatesHistogramWithRequestBuilder(startDate: startDate, endDate: endDate, sdid: sdid, field: field, interval: interval).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get Normalized Message Histogram
     
     - parameter startDate: (query) Timestamp of earliest message (in milliseconds since epoch). 
     - parameter endDate: (query) Timestamp of latest message (in milliseconds since epoch). 
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter field: (query) Message field being queried for building histogram. (optional)
     - parameter interval: (query) Interval of time for building histogram blocks. (Valid values: minute, hour, day, month, year) (optional)
     - returns: Promise<AggregatesHistogramResponse>
     */
    public class func getAggregatesHistogram(startDate startDate: Int64, endDate: Int64, sdid: String? = nil, field: String? = nil, interval: String? = nil) -> Promise<AggregatesHistogramResponse> {
        let deferred = Promise<AggregatesHistogramResponse>.pendingPromise()
        getAggregatesHistogram(startDate: startDate, endDate: endDate, sdid: sdid, field: field, interval: interval) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get Normalized Message Histogram
     - GET /messages/analytics/histogram
     - Get Histogram on normalized messages.
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "data" : [ {
    "min" : 1.3579000000000001069366817318950779736042022705078125,
    "max" : 1.3579000000000001069366817318950779736042022705078125,
    "variance" : 1.3579000000000001069366817318950779736042022705078125,
    "mean" : 1.3579000000000001069366817318950779736042022705078125,
    "count" : 123456789,
    "sum" : 1.3579000000000001069366817318950779736042022705078125,
    "ts" : 123456789
  } ],
  "field" : "aeiou",
  "size" : 123456789,
  "endDate" : 123456789,
  "sdid" : "aeiou",
  "interval" : "aeiou",
  "startDate" : 123456789
}}]
     
     - parameter startDate: (query) Timestamp of earliest message (in milliseconds since epoch). 
     - parameter endDate: (query) Timestamp of latest message (in milliseconds since epoch). 
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter field: (query) Message field being queried for building histogram. (optional)
     - parameter interval: (query) Interval of time for building histogram blocks. (Valid values: minute, hour, day, month, year) (optional)

     - returns: RequestBuilder<AggregatesHistogramResponse> 
     */
    public class func getAggregatesHistogramWithRequestBuilder(startDate startDate: Int64, endDate: Int64, sdid: String? = nil, field: String? = nil, interval: String? = nil) -> RequestBuilder<AggregatesHistogramResponse> {
        let path = "/messages/analytics/histogram"
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "startDate": startDate.encodeToJSON(),
            "endDate": endDate.encodeToJSON(),
            "sdid": sdid,
            "field": field,
            "interval": interval
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<AggregatesHistogramResponse>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get normalized message presence
     
     - parameter startDate: (query) startDate 
     - parameter endDate: (query) endDate 
     - parameter interval: (query) String representing grouping interval. One of: &#39;minute&#39; (1 hour limit), &#39;hour&#39; (1 day limit), &#39;day&#39; (31 days limit), &#39;month&#39; (1 year limit), or &#39;year&#39; (10 years limit). 
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getFieldPresence(startDate startDate: Int64, endDate: Int64, interval: String, sdid: String? = nil, fieldPresence: String? = nil, completion: ((data: FieldPresenceEnvelope?, error: ErrorType?) -> Void)) {
        getFieldPresenceWithRequestBuilder(startDate: startDate, endDate: endDate, interval: interval, sdid: sdid, fieldPresence: fieldPresence).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get normalized message presence
     
     - parameter startDate: (query) startDate 
     - parameter endDate: (query) endDate 
     - parameter interval: (query) String representing grouping interval. One of: &#39;minute&#39; (1 hour limit), &#39;hour&#39; (1 day limit), &#39;day&#39; (31 days limit), &#39;month&#39; (1 year limit), or &#39;year&#39; (10 years limit). 
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)
     - returns: Promise<FieldPresenceEnvelope>
     */
    public class func getFieldPresence(startDate startDate: Int64, endDate: Int64, interval: String, sdid: String? = nil, fieldPresence: String? = nil) -> Promise<FieldPresenceEnvelope> {
        let deferred = Promise<FieldPresenceEnvelope>.pendingPromise()
        getFieldPresence(startDate: startDate, endDate: endDate, interval: interval, sdid: sdid, fieldPresence: fieldPresence) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get normalized message presence
     - GET /messages/presence
     - Get normalized message presence.
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "fieldPresence" : "aeiou",
  "size" : 123456789,
  "data" : [ {
    "startDate" : 123456789
  } ],
  "endDate" : 123456789,
  "sdid" : "aeiou",
  "interval" : "aeiou",
  "startDate" : 123456789
}}]
     
     - parameter startDate: (query) startDate 
     - parameter endDate: (query) endDate 
     - parameter interval: (query) String representing grouping interval. One of: &#39;minute&#39; (1 hour limit), &#39;hour&#39; (1 day limit), &#39;day&#39; (31 days limit), &#39;month&#39; (1 year limit), or &#39;year&#39; (10 years limit). 
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)

     - returns: RequestBuilder<FieldPresenceEnvelope> 
     */
    public class func getFieldPresenceWithRequestBuilder(startDate startDate: Int64, endDate: Int64, interval: String, sdid: String? = nil, fieldPresence: String? = nil) -> RequestBuilder<FieldPresenceEnvelope> {
        let path = "/messages/presence"
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "sdid": sdid,
            "fieldPresence": fieldPresence,
            "startDate": startDate.encodeToJSON(),
            "endDate": endDate.encodeToJSON(),
            "interval": interval
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<FieldPresenceEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get Last Normalized Message
     
     - parameter count: (query) Number of items to return per query. (optional)
     - parameter sdids: (query) Comma separated list of source device IDs (minimum: 1). (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getLastNormalizedMessages(count count: Int32? = nil, sdids: String? = nil, fieldPresence: String? = nil, completion: ((data: NormalizedMessagesEnvelope?, error: ErrorType?) -> Void)) {
        getLastNormalizedMessagesWithRequestBuilder(count: count, sdids: sdids, fieldPresence: fieldPresence).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get Last Normalized Message
     
     - parameter count: (query) Number of items to return per query. (optional)
     - parameter sdids: (query) Comma separated list of source device IDs (minimum: 1). (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)
     - returns: Promise<NormalizedMessagesEnvelope>
     */
    public class func getLastNormalizedMessages(count count: Int32? = nil, sdids: String? = nil, fieldPresence: String? = nil) -> Promise<NormalizedMessagesEnvelope> {
        let deferred = Promise<NormalizedMessagesEnvelope>.pendingPromise()
        getLastNormalizedMessages(count: count, sdids: sdids, fieldPresence: fieldPresence) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get Last Normalized Message
     - GET /messages/last
     - Get last messages normalized.
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "next" : "aeiou",
  "uid" : "aeiou",
  "sdids" : "aeiou",
  "size" : 123456789,
  "data" : [ {
    "uid" : "aeiou",
    "cts" : 123456789,
    "data" : {
      "key" : "{}"
    },
    "mid" : "aeiou",
    "sdid" : "aeiou",
    "mv" : 123,
    "sdtid" : "aeiou",
    "ts" : 123456789
  } ],
  "endDate" : 123456789,
  "count" : 123456789,
  "sdid" : "aeiou",
  "startDate" : 123456789,
  "order" : "aeiou"
}}]
     
     - parameter count: (query) Number of items to return per query. (optional)
     - parameter sdids: (query) Comma separated list of source device IDs (minimum: 1). (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)

     - returns: RequestBuilder<NormalizedMessagesEnvelope> 
     */
    public class func getLastNormalizedMessagesWithRequestBuilder(count count: Int32? = nil, sdids: String? = nil, fieldPresence: String? = nil) -> RequestBuilder<NormalizedMessagesEnvelope> {
        let path = "/messages/last"
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "count": count?.encodeToJSON(),
            "sdids": sdids,
            "fieldPresence": fieldPresence
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<NormalizedMessagesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get Normalized Message Aggregates
     
     - parameter sdid: (query) Source device ID of the messages being searched. 
     - parameter field: (query) Message field being queried for aggregates. 
     - parameter startDate: (query) Timestamp of earliest message (in milliseconds since epoch). 
     - parameter endDate: (query) Timestamp of latest message (in milliseconds since epoch). 
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getMessageAggregates(sdid sdid: String, field: String, startDate: Int64, endDate: Int64, completion: ((data: AggregatesResponse?, error: ErrorType?) -> Void)) {
        getMessageAggregatesWithRequestBuilder(sdid: sdid, field: field, startDate: startDate, endDate: endDate).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get Normalized Message Aggregates
     
     - parameter sdid: (query) Source device ID of the messages being searched. 
     - parameter field: (query) Message field being queried for aggregates. 
     - parameter startDate: (query) Timestamp of earliest message (in milliseconds since epoch). 
     - parameter endDate: (query) Timestamp of latest message (in milliseconds since epoch). 
     - returns: Promise<AggregatesResponse>
     */
    public class func getMessageAggregates(sdid sdid: String, field: String, startDate: Int64, endDate: Int64) -> Promise<AggregatesResponse> {
        let deferred = Promise<AggregatesResponse>.pendingPromise()
        getMessageAggregates(sdid: sdid, field: field, startDate: startDate, endDate: endDate) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get Normalized Message Aggregates
     - GET /messages/analytics/aggregates
     - Get Aggregates on normalized messages.
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "data" : [ {
    "min" : 1.3579000000000001069366817318950779736042022705078125,
    "max" : 1.3579000000000001069366817318950779736042022705078125,
    "variance" : 1.3579000000000001069366817318950779736042022705078125,
    "mean" : 1.3579000000000001069366817318950779736042022705078125,
    "count" : 123456789,
    "sum" : 1.3579000000000001069366817318950779736042022705078125
  } ],
  "field" : "aeiou",
  "size" : 123,
  "endDate" : 123456789,
  "sdid" : "aeiou",
  "startDate" : 123456789
}}]
     
     - parameter sdid: (query) Source device ID of the messages being searched. 
     - parameter field: (query) Message field being queried for aggregates. 
     - parameter startDate: (query) Timestamp of earliest message (in milliseconds since epoch). 
     - parameter endDate: (query) Timestamp of latest message (in milliseconds since epoch). 

     - returns: RequestBuilder<AggregatesResponse> 
     */
    public class func getMessageAggregatesWithRequestBuilder(sdid sdid: String, field: String, startDate: Int64, endDate: Int64) -> RequestBuilder<AggregatesResponse> {
        let path = "/messages/analytics/aggregates"
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "sdid": sdid,
            "field": field,
            "startDate": startDate.encodeToJSON(),
            "endDate": endDate.encodeToJSON()
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<AggregatesResponse>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get Message Snapshots
     
     - parameter sdids: (query) Device IDs for which the snapshots are requested. Max 100 device ids per call. 
     - parameter includeTimestamp: (query) Indicates whether to return timestamps of the last update for each field. (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getMessageSnapshots(sdids sdids: String, includeTimestamp: Bool? = nil, completion: ((data: SnapshotResponses?, error: ErrorType?) -> Void)) {
        getMessageSnapshotsWithRequestBuilder(sdids: sdids, includeTimestamp: includeTimestamp).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get Message Snapshots
     
     - parameter sdids: (query) Device IDs for which the snapshots are requested. Max 100 device ids per call. 
     - parameter includeTimestamp: (query) Indicates whether to return timestamps of the last update for each field. (optional)
     - returns: Promise<SnapshotResponses>
     */
    public class func getMessageSnapshots(sdids sdids: String, includeTimestamp: Bool? = nil) -> Promise<SnapshotResponses> {
        let deferred = Promise<SnapshotResponses>.pendingPromise()
        getMessageSnapshots(sdids: sdids, includeTimestamp: includeTimestamp) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get Message Snapshots
     - GET /messages/snapshots
     - Get message snapshots.
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "sdids" : "aeiou",
  "size" : 123,
  "data" : [ {
    "data" : {
      "key" : "{}"
    },
    "sdid" : "aeiou"
  } ]
}}]
     
     - parameter sdids: (query) Device IDs for which the snapshots are requested. Max 100 device ids per call. 
     - parameter includeTimestamp: (query) Indicates whether to return timestamps of the last update for each field. (optional)

     - returns: RequestBuilder<SnapshotResponses> 
     */
    public class func getMessageSnapshotsWithRequestBuilder(sdids sdids: String, includeTimestamp: Bool? = nil) -> RequestBuilder<SnapshotResponses> {
        let path = "/messages/snapshots"
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "sdids": sdids,
            "includeTimestamp": includeTimestamp
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<SnapshotResponses>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Get Normalized Messages
     
     - parameter uid: (query) User ID. If not specified, assume that of the current authenticated user. If specified, it must be that of a user for which the current authenticated user has read access to. (optional)
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter mid: (query) The SAMI message ID being searched. (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)
     - parameter filter: (query) Filter. (optional)
     - parameter offset: (query) A string that represents the starting item, should be the value of &#39;next&#39; field received in the last response. (required for pagination) (optional)
     - parameter count: (query) count (optional)
     - parameter startDate: (query) startDate (optional)
     - parameter endDate: (query) endDate (optional)
     - parameter order: (query) Desired sort order: &#39;asc&#39; or &#39;desc&#39; (optional)
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func getNormalizedMessages(uid uid: String? = nil, sdid: String? = nil, mid: String? = nil, fieldPresence: String? = nil, filter: String? = nil, offset: String? = nil, count: Int32? = nil, startDate: Int64? = nil, endDate: Int64? = nil, order: String? = nil, completion: ((data: NormalizedMessagesEnvelope?, error: ErrorType?) -> Void)) {
        getNormalizedMessagesWithRequestBuilder(uid: uid, sdid: sdid, mid: mid, fieldPresence: fieldPresence, filter: filter, offset: offset, count: count, startDate: startDate, endDate: endDate, order: order).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Get Normalized Messages
     
     - parameter uid: (query) User ID. If not specified, assume that of the current authenticated user. If specified, it must be that of a user for which the current authenticated user has read access to. (optional)
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter mid: (query) The SAMI message ID being searched. (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)
     - parameter filter: (query) Filter. (optional)
     - parameter offset: (query) A string that represents the starting item, should be the value of &#39;next&#39; field received in the last response. (required for pagination) (optional)
     - parameter count: (query) count (optional)
     - parameter startDate: (query) startDate (optional)
     - parameter endDate: (query) endDate (optional)
     - parameter order: (query) Desired sort order: &#39;asc&#39; or &#39;desc&#39; (optional)
     - returns: Promise<NormalizedMessagesEnvelope>
     */
    public class func getNormalizedMessages(uid uid: String? = nil, sdid: String? = nil, mid: String? = nil, fieldPresence: String? = nil, filter: String? = nil, offset: String? = nil, count: Int32? = nil, startDate: Int64? = nil, endDate: Int64? = nil, order: String? = nil) -> Promise<NormalizedMessagesEnvelope> {
        let deferred = Promise<NormalizedMessagesEnvelope>.pendingPromise()
        getNormalizedMessages(uid: uid, sdid: sdid, mid: mid, fieldPresence: fieldPresence, filter: filter, offset: offset, count: count, startDate: startDate, endDate: endDate, order: order) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Get Normalized Messages
     - GET /messages
     - Get the messages normalized
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "next" : "aeiou",
  "uid" : "aeiou",
  "sdids" : "aeiou",
  "size" : 123456789,
  "data" : [ {
    "uid" : "aeiou",
    "cts" : 123456789,
    "data" : {
      "key" : "{}"
    },
    "mid" : "aeiou",
    "sdid" : "aeiou",
    "mv" : 123,
    "sdtid" : "aeiou",
    "ts" : 123456789
  } ],
  "endDate" : 123456789,
  "count" : 123456789,
  "sdid" : "aeiou",
  "startDate" : 123456789,
  "order" : "aeiou"
}}]
     
     - parameter uid: (query) User ID. If not specified, assume that of the current authenticated user. If specified, it must be that of a user for which the current authenticated user has read access to. (optional)
     - parameter sdid: (query) Source device ID of the messages being searched. (optional)
     - parameter mid: (query) The SAMI message ID being searched. (optional)
     - parameter fieldPresence: (query) String representing a field from the specified device ID. (optional)
     - parameter filter: (query) Filter. (optional)
     - parameter offset: (query) A string that represents the starting item, should be the value of &#39;next&#39; field received in the last response. (required for pagination) (optional)
     - parameter count: (query) count (optional)
     - parameter startDate: (query) startDate (optional)
     - parameter endDate: (query) endDate (optional)
     - parameter order: (query) Desired sort order: &#39;asc&#39; or &#39;desc&#39; (optional)

     - returns: RequestBuilder<NormalizedMessagesEnvelope> 
     */
    public class func getNormalizedMessagesWithRequestBuilder(uid uid: String? = nil, sdid: String? = nil, mid: String? = nil, fieldPresence: String? = nil, filter: String? = nil, offset: String? = nil, count: Int32? = nil, startDate: Int64? = nil, endDate: Int64? = nil, order: String? = nil) -> RequestBuilder<NormalizedMessagesEnvelope> {
        let path = "/messages"
        let URLString = ArtikCloudAPI.basePath + path

        let nillableParameters: [String:AnyObject?] = [
            "uid": uid,
            "sdid": sdid,
            "mid": mid,
            "fieldPresence": fieldPresence,
            "filter": filter,
            "offset": offset,
            "count": count?.encodeToJSON(),
            "startDate": startDate?.encodeToJSON(),
            "endDate": endDate?.encodeToJSON(),
            "order": order
        ]
 
        let parameters = APIHelper.rejectNil(nillableParameters)
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<NormalizedMessagesEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "GET", URLString: URLString, parameters: convertedParameters, isBody: false)
    }

    /**
     Send Message Action
     
     - parameter data: (body) Message or Action object that is passed in the body 
     - parameter completion: completion handler to receive the data and the error objects
     */
    public class func sendMessageAction(data data: MessageAction, completion: ((data: MessageIDEnvelope?, error: ErrorType?) -> Void)) {
        sendMessageActionWithRequestBuilder(data: data).execute { (response, error) -> Void in
            completion(data: response?.body, error: error);
        }
    }

    /**
     Send Message Action
     
     - parameter data: (body) Message or Action object that is passed in the body 
     - returns: Promise<MessageIDEnvelope>
     */
    public class func sendMessageAction(data data: MessageAction) -> Promise<MessageIDEnvelope> {
        let deferred = Promise<MessageIDEnvelope>.pendingPromise()
        sendMessageAction(data: data) { data, error in
            if let error = error {
                deferred.reject(error)
            } else {
                deferred.fulfill(data!)
            }
        }
        return deferred.promise
    }

    /**
     Send Message Action
     - POST /messages
     - (Deprecated) Send a message or an Action:<br/><table><tr><th>Combination</th><th>Parameters</th><th>Description</th></tr><tr><td>Send Message</td><td>sdid, type=message</td><td>Send a message from a Source Device</td></tr><tr><td>Send Action</td><td>ddid, type=action</td><td>Send an action to a Destination Device</td></tr><tr><td>Common</td><td>data, ts, token</td><td>Parameters that can be used with the above combinations.</td></tr></table>
     - OAuth:
       - type: oauth2
       - name: artikcloud_oauth
     - examples: [{contentType=application/json, example={
  "data" : {
    "mid" : "aeiou"
  }
}}]
     
     - parameter data: (body) Message or Action object that is passed in the body 

     - returns: RequestBuilder<MessageIDEnvelope> 
     */
    public class func sendMessageActionWithRequestBuilder(data data: MessageAction) -> RequestBuilder<MessageIDEnvelope> {
        let path = "/messages"
        let URLString = ArtikCloudAPI.basePath + path
        let parameters = data.encodeToJSON() as? [String:AnyObject]
 
        let convertedParameters = APIHelper.convertBoolToString(parameters)
 
        let requestBuilder: RequestBuilder<MessageIDEnvelope>.Type = ArtikCloudAPI.requestBuilderFactory.getBuilder()

        return requestBuilder.init(method: "POST", URLString: URLString, parameters: convertedParameters, isBody: true)
    }

}
