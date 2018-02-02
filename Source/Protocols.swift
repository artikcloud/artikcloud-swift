//
//  ManageableArtikInstance.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/16/17.
//  Copyright © 2017 Paul-Valentin Mini. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - SDK Delegate

@objc public protocol ArtikCloudSwiftDelegate: class {
    @objc optional func maxPayload(_ size: UInt64)
    @objc optional func rateLimit(_ rate: APIRateLimit)
    @objc optional func organizationQuota(_ quota: APIOrganizationQuota)
    @objc optional func deviceQuota(_ quota: APIDeviceQuota)
    @objc optional func tokenRefreshed(_ token: UserToken)
}

// MARK: - ARTIK Instance Protocols

public protocol PullableArtikInstance {
    func pullFromArtik() -> Promise<Void>
}

public protocol AccessibleArtikInstance: PullableArtikInstance {
    func updateOnArtik() -> Promise<Void>
}

public protocol RemovableArtikInstance {
    func removeFromArtik() -> Promise<Void>
}

public protocol ManageableArtikInstance: AccessibleArtikInstance, RemovableArtikInstance {
    func createOrDuplicateOnArtik() -> Promise<ManageableArtikInstance>
}
