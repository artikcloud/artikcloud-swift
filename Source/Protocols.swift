//
//  ManageableArtikInstance.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 5/16/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - SDK Delegate

public protocol ArtikCloudSwiftDelegate: class {
    func maxPayload(_ size: UInt64)
    func rateLimit(_ rate: APIRateLimit)
    func organizationQuota(_ quota: APIOrganizationQuota)
    func deviceQuota(_ quota: APIDeviceQuota)
    func tokenRefreshed(_ token: UserToken)
}

public extension ArtikCloudSwiftDelegate {
    func maxPayload(_ size: UInt64) {}
    func rateLimit(_ rate: ArtikCloudSwift.APIRateLimit) {}
    func organizationQuota(_ quota: ArtikCloudSwift.APIOrganizationQuota) {}
    func deviceQuota(_ quota: ArtikCloudSwift.APIDeviceQuota) {}
    func tokenRefreshed(_ token: ArtikCloudSwift.UserToken) {}
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
