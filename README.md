# ArtikCloudSwift
![Supported Version](https://img.shields.io/badge/Swift-4.0-green.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![CocoaPods](https://img.shields.io/badge/CocoaPods-1.1-green.svg)
![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg)

This SDK helps you connect your iOS, tvOS, watchOS, and macOS applications to ARTIK cloud services. It exposes a number of methods to easily execute REST and WebSockets calls to ARTIK cloud services.

## Specifications

Connect with ARTIK cloud services and handle its response asynchronously. 
```swift
DevicesAPI.get(id: "example-id").done { device in
    if device.isSharable() {
        device.share(email: "email@example.com").catch { error in
            print(error)
        }
    } else {
        device.removeFromArtik().done {
            print("We couldn't share the device, so it was removed.")
        }.catch { error in
            print(error)
        }
    }
}.catch { error in
    print(error)
}
```

## Prerequisites

- [Alamofire](https://github.com/Alamofire/Alamofire) >= 4.7.1
- [PromiseKit](https://github.com/mxcl/PromiseKit) >= 6.2.3
- [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) >= 3.1.0
- [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) >= 0.9.0
- [Starscream](https://github.com/daltoniam/Starscream) >= 3.0.5

## Installation

### CocoaPods

[CocoaPods 1.1](https://guides.cocoapods.org/using/getting-started.html) or higher is required. 

Specify `ArtikCloudSwift` in your `PodFile` using one of the following:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'ArtikCloudSwift'
```

Then run the following command:
```
pod install
```

### Manual installation

Drop `ArtikCloudSwift.xcodeproj` into your project and add `ArtikCloudSwift.framework` to your application's embedded frameworks.

## Getting Started

```swift
import ArtikCloudSwift
```

### Application setup

Before you begin making requests, provide the client ID and redirect URI of your application.
```swift
ArtikCloudSwiftSettings.clientID = "my-clientid"
ArtikCloudSwiftSettings.redirectURI = "my-uri://"
``` 
To learn how to create an application on ARTIK cloud services and obtain its client ID (application ID) and redirect URI, read our [documentation](https://developer.artik.cloud/documentation/tools/web-tools.html#creating-an-application).

### Authentication

API calls require authentication, and you must obtain a `Token` through any of the available [authentication flows](https://developer.artik.cloud/documentation/user-management/authentication.html). These flows are implemented in `AuthenticationAPI`. This [How To guide](https://developer.artik.cloud/documentation/tutorials/how-to/choose-oauth2-method.html) describes how to choose the best authentication flow for your use case.

Once you have obtained a `Token`, set it using one of the following methods:
```swift
ArtikCloudSwiftSettings.setUserToken(_ token: UserToken)
ArtikCloudSwiftSettings.setApplicationToken(_ token: ApplicationToken)
ArtikCloudSwiftSettings.setDeviceToken(_ token: DeviceToken)
```
Each time a token is used, its validity is verified locally (if possible). For a `UserToken` that has expired, the framework will attempt to refresh it with ARTIK cloud services before executing the request. This can be disabled by setting `ArtikCloudSwiftSettings.attemptToRefreshToken = false`.

### Using multiple token types

If you plan on using multiple `Token` types for different requests, you can set `preferredTokenForRequests` to a certain `Token.Type`. The framework will first attempt to use this token type before falling back on other types if unavailable. For example, to prioritize the current `ApplicationToken`:
```swift
ArtikCloudSwiftSettings.preferredTokenForRequests = ApplicationToken.self
```

### Handling callbacks

When using certain APIs, ARTIK cloud services will attempt a callback to your application, such as when using the [Authorization Code](https://developer.artik.cloud/documentation/user-management/authentication.html#authorization-code-method) authentication flow or upgrading a device type for [Monetization](https://developer.artik.cloud/documentation/monetization.html). For this to work, first make sure that the redirect URI of your application (server-side), your URL scheme (client-side), and `ArtikCloudSwiftSettings.redirectURI` are set to the same value.

Once your application receives a callback, identify which flow it is targeting by passing the `URL` to `ArtikCloudSwiftSettings.identifyRedirectEndpoint(_ callback: URL)`. Use the `RedirectEndpoint` value returned to determine how to process it.

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
            AuthenticationAPI.processAuthorizationCodeCallback(url, usingPKCE: true).done { token in
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

You can set `ArtikCloudSwiftSettings.delegate` to stay informed of various usage-related data. All methods are optional.
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
*Called after an API is used counting towards a device's quota.*
<br><br>
```swift
func tokenRefreshed(_ token: UserToken)
```
*Called each time the current `UserToken` has been refreshed. Use this method to save the newly refreshed token if needed.*
<br><br>

### WebSockets

ARTIK cloud services' WebSockets are easily accesible using their respective implementations: `EventsWebsocket`, `LiveWebsocket`, and `DeviceWebsocket`. Once initialized, use `.connect()` and `.disconnect()` to initiate or terminate their connections. You can also make use of their delegates to react to any of their connection events, messages, etc.  
_NOTE: Websocket features are not available on watchOS at this time (missing access to CFNetwork String constants)._

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

## API documentation

Markup documentation is available for all API methods in their [respective source files](https://github.com/artikcloud/artikcloud-swift/tree/master/Source). 

You can also refer to our documentation.

### REST
- [Users](https://developer.artik.cloud/documentation/api-reference/rest-api.html#users)
- [Devices](https://developer.artik.cloud/documentation/api-reference/rest-api.html#devices)
- [Device Types](https://developer.artik.cloud/documentation/api-reference/rest-api.html#device-types)
- [Messages](https://developer.artik.cloud/documentation/api-reference/rest-api.html#messages)
- [Monetization](https://developer.artik.cloud/documentation/api-reference/rest-api.html#monetization)
- [Subscriptions](https://developer.artik.cloud/documentation/api-reference/rest-api.html#subscriptions)
- [Notifications](https://developer.artik.cloud/documentation/api-reference/rest-api.html#notifications)
- [Rules](https://developer.artik.cloud/documentation/api-reference/rest-api.html#rules)
- [Scenes](https://developer.artik.cloud/documentation/api-reference/rest-api.html#scenes)
- [Machine Learning](https://developer.artik.cloud/documentation/api-reference/rest-api.html#machine-learning)
- [Device Management](https://developer.artik.cloud/documentation/api-reference/rest-api.html#device-management)

### WebSockets
- [Events](https://developer.artik.cloud/documentation/api-reference/websockets-api.html#event-feed-websocket)
- [Live (Firehose)](https://developer.artik.cloud/documentation/api-reference/websockets-api.html#firehose-websocket)
- [Device](https://developer.artik.cloud/documentation/api-reference/websockets-api.html#device-channel-websocket)

## More about ARTIK Cloud

If you are not familiar with ARTIK cloud services, we have extensive documentation at https://developer.artik.cloud/documentation

The full ARTIK cloud services API specification can be found at https://developer.artik.cloud/documentation/api-reference/

Check out advanced sample applications at https://developer.artik.cloud/documentation/tutorials/code-samples/

To create and manage your services and devices on ARTIK cloud services, create an account at https://developer.artik.cloud

Also see the ARTIK cloud services blog for tutorials, updates, and more: http://artik.io/blog/cloud

## Licence and Copyright

Licensed under the Apache License. See [LICENSE](https://github.com/artikcloud/artikcloud-swift/blob/master/LICENSE).

Copyright © 2017-2018 Samsung Electronics Co., Ltd.