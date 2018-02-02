# ArtikCloudSwift
![Supported Version](https://img.shields.io/badge/Swift-4.0-green.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-1.1-green.svg)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg)

ARTIK Cloud is an open data exchange platform for the Internet of Things (IoT).

## Specifications

Connect with ARTIK Cloud and handle its response asynchronously 
```swift
DevicesAPI.get(id: "example-id").then { device -> Void in
    if device.isSharable() {
        device.share(email: "email@example.com").catch { error in
            print(error)
        }
    } else {
        device.removeFromArtik().then { _ -> Void in
            print("We couldn't share the device, so it was removed.")
        }.catch { error in
            print(error)
        }
    }
}.catch { error in
    print(error)
}
```
Most classes have convenience methods to easily act upon your Users, Devices, Messages, Rules, etc.

### Endpoints
- [x] Users
- [x] Devices
- [x] Device Types
- [x] Messages
- [x] Monetization
- [x] Subscriptions
- [x] Notifications
- [x] Rules
- [x] Scenes
- [x] Machine Learning
- [x] Device Management

### Websockets
- [x] Events
- [x] Live (Firehose)
- [x] Device

### Features
- [x] Authorization Code (+ PKCE) Authentication
- [x] Implicit Authentication
- [x] Limited Input Authentication
- [x] Client Credentials Authentication
- [x] Automatic Token Management and Refreshing
- [x] Delegate for Rate Limit/Quota Monitoring
- [x] Simplified Callback Handling

## Requirements

- [Alamofire](https://github.com/Alamofire/Alamofire) >= 4.5.1
- [PromiseKit](https://github.com/mxcl/PromiseKit) >= 4.5.0
- [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) >= 3.1.0
- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) >= 0.8.0
- [Starscream](https://github.com/daltoniam/Starscream) >= 3.0.3

## Installation

### CocoaPods

This SDK requires [CocoaPods 1.1+](https://guides.cocoapods.org/using/getting-started.html) to be installed. 
To install it, specify `ArtikCloudSwift` in your `PodFile` using one of the following:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'ArtikCloudSwift'
```

Then run the following command:
```
pod install
```

### Manual Install

Drop `ArtikCloudSwift.xcodeproj` into your project and add `ArtikCloudSwift.framework` to your app's embedded frameworks.

## Getting Started

```swift
import ArtikCloudSwift
```

### ARTIK Application Settings

Before you begin making requests, make sure to provide the Client ID and redirect URI of your ARTIK Cloud Application. 
```swift
ArtikCloudSwiftSettings.clientID = "my-clientid"
ArtikCloudSwiftSettings.redirectURI = "my-uri://"
``` 
For more information on how to create an ARTIK Cloud application, obtaining its Client ID or getting its redirect URI, visit the following [tutorial](https://developer.artik.cloud/documentation/tools/web-tools.html#creating-an-application).

### Authentication

If you plan to make API calls which require authentication, you will need to obtain a `Token` through any of the available [authentication flows](https://developer.artik.cloud/documentation/user-management/authentication.html). These are all implemented in `AuthenticationAPI`, pick which ever fits your needs best.

Once you have obtained a `Token`, you can set it using the following methods:
```swift
ArtikCloudSwiftSettings.setUserToken(_ token: UserToken)
ArtikCloudSwiftSettings.setApplicationToken(_ token: ApplicationToken)
ArtikCloudSwiftSettings.setDeviceToken(_ token: DeviceToken)
```
Every time a token is used, its validity is verified locally (if possible). For `UserToken`s that have expired, the framework will attempt to refresh it with ARTIK Cloud before executing the request, which can be disabled by setting `ArtikCloudSwiftSettings.attemptToRefreshToken = false`.

### Using Multiple Types of Tokens

If you plan on using multiple types of `Token` for different requests, you can set `preferredTokenForRequests` to a certain `Token.Type` and the framework will attempt to use it first before falling back on other types if unavailable. For example, to prioritize the current `ApplicationToken`:
```swift
ArtikCloudSwiftSettings.preferredTokenForRequests = ApplicationToken.self
```

### Handling Callbacks

When using certain APIs, ARTIK Cloud will attempt to callback to your application, such as when using Authorization Code Authentication or upgrading a device. For this to work, first make sure that the Redirect URI of your ARTIK Application (server-side), your URL Scheme (client-side) and `ArtikCloudSwiftSettings.redirectURI` are set to the same value.

Once your application receives a callback, identify which flow it is targetting by passing the `URL` to `ArtikCloudSwiftSettings.identifyRedirectEndpoint(_ callback: URL)` and use the `RedirectEndpoint` value returned to determine how to process it.

```swift
// iOS Example
func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    if let endpoint = ArtikCloudSwiftSettings.identifyRedirectEndpoint(url) {
        switch endpoint {
        case .cloudAuthorization:
            // User was authorizing a Cloud Connector
        case .monetization:
        	// User has attempted to upgrade a device
            do {
                if try MonetizationAPI.processUpgradeCallback(url) == .accepted {
                	// Device was upgraded!
                }
            } catch {
                // Unable to determine upgrade result
            }
        case .logout:
            // User has logged out
        default:
            // Default Callback, used for Authentication flows
            
            // Using Authorization Code + PKCE for example...
            AuthenticationAPI.processAuthorizationCodeCallback(url, usingPKCE: true).then { token -> Void in
                // We got a Token!
            }.catch { error -> Void in
                // Something went wrong...
            }
        }
    }
    return true
}
```

### ArtikCloudSwiftDelegate

You can set `ArtikCloudSwiftSettings.delegate` to stay informed of various usage related data. All methods are optional.
<br><br>
```swift
func maxPayload(_ size: UInt64)
```
*Called every time a response is received specifying the API's maximum accepted payload size.*
<br><br>
```swift
func rateLimit(_ rate: APIRateLimit)
```
*Called after an API is used, informing you of the current state of your rate limit.*
<br><br>
```swift
func organizationQuota(_ quota: APIOrganizationQuota)
```
*Called after an API is used, informing you of your remaining organization quota.*
<br><br>
```swift
func deviceQuota(_ quota: APIDeviceQuota)
```
*Called after an API is used counting towards a Device's Quota.*
<br><br>
```swift
func tokenRefreshed(_ token: UserToken)
```
*Called every time the current `UserToken` has been refreshed. Use this method to save the newly refreshed token if needed.*
<br><br>

### Websockets

ARTIK Cloud's websockets are easily accesible using their respective implementations: `EventsWebsocket`, `LiveWebsocket`, and `DeviceWebsocket`. Once initialized use `.connect()` and `.disconnect()` to initiate or terminate their connections. You can also make use of their delegates to react to any of their connection events, messages, etc.  
_NOTE: Websocket features are not available on WatchOS at this time (missing access to CFNetwork String constants)._

#### ArtikWebsocketDelegate (implemented by all delegates below)
```swift
func websocketDidConnect(socket: ArtikWebsocket)
```
*Called when the socket has successfuly established a connection.*
<br><br>
```swift
func websocketDidDisconnect(socket: ArtikWebsocket, reconnecting: Bool, error: Error?)
```
*Called when the socket has been disconnected, indicating if it was due to an error and if it is attempting to reconnect.*
<br><br>
```swift
func websocketEncounteredError(socket: ArtikWebsocket, error: Error)
```
*Called when an error occured while performing an operation.*

#### EventsWebsocketDelegate
```swift
func websocketDidReceiveEvent(socket: EventsWebsocket, event: EventsWebsocket.EventType, uid: String?, aid: String?, did: String?, dtid: String?, ts: ArtikTimestamp)
```
*Called when the socket receives an event.*

#### LiveWebsocketDelegate
```swift
func websocketDidReceiveMessage(socket: LiveWebsocket, mid: String, data: [String:Any], sdid: String, sdtid: String?, uid: String?, ts: ArtikTimestamp)
```
*Called when the socket receives a message.*

#### DeviceWebsocketDelegate
```swift
func websocketDidReceiveAction(socket: DeviceWebsocket, mid: String, data: [String:Any], ddid: String)
```
*Called when the socket receives an action for a device.*

## Additional Documentation

Markup documentation is available for all API methods. You can also refer to the [ARTIK Cloud REST API Documentation](https://developer.artik.cloud/documentation/api-reference/rest-api.html). 

## Licence and Copyright

Licensed under the Apache License. See [LICENSE](https://github.com/artikcloud/artikcloud-swift/blob/master/LICENSE).

Written with ❤️ by [Paul-Valentin Mini](https://github.com/Laptopmini) for [SAMSUNG](http://www.samsung.com/us/ssic/).

Copyright © 2017-2018 Samsung Electronics Co., Ltd.
