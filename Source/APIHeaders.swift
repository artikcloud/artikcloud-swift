//
//  APIHeaders.swift
//  ArtikCloudSwift
//
//  Created by Paul-Valentin Mini on 6/7/17.
//  Copyright © 2017-2018 Samsung Electronics Co., Ltd. All rights reserved.
//

import Foundation

public class APIRequestCountValues {
    public let slidingMinute: ArtikRequestCount
    public let daily: ArtikRequestCount
    
    init(slidingMinute: ArtikRequestCount, daily: ArtikRequestCount) {
        self.slidingMinute = slidingMinute
        self.daily = daily
    }
}

public class APIResetValues {
    public let slidingMinute: Int64 // Seconds
    public let daily: Int64 // Seconds
    
    init(slidingMinute: Int64, daily: Int64) {
        self.slidingMinute = slidingMinute
        self.daily = daily
    }
}

public class APILimitValues {
    public let current: ArtikRequestCount
    public let max: ArtikRequestCount
    
    init(current: ArtikRequestCount, max: ArtikRequestCount) {
        self.current = current
        self.max = max
    }
}

public class APIDeviceQuota: NSObject {
    public let reset: ArtikTimestamp
    public let limit: APILimitValues
    
    init(reset: ArtikTimestamp, limit: APILimitValues) {
        self.reset = reset
        self.limit = limit
    }
    
    init?(limits: String, reset: String) {
        let limitsValues = limits.components(separatedBy: "/")
        let resetValues = reset.components(separatedBy: "/")
        
        let count = limitsValues.count
        if count == 2 && count == resetValues.count {
            if let limitMax = UInt64(limitsValues[1]), let limitCurrent = UInt64(limitsValues[0]), let reset = Int64(resetValues[1]) {
                self.limit = APILimitValues(current: limitCurrent, max: limitMax)
                self.reset = reset
                return
            }
        }
        return nil
    }
}

public class APIOrganizationQuota: NSObject {
    public let start: ArtikTimestamp
    public let end: ArtikTimestamp
    public let limit: APILimitValues
    
    init(start: ArtikTimestamp, end: ArtikTimestamp, limit: APILimitValues) {
        self.start = start
        self.end = end
        self.limit = limit
    }
    
    init?(limits: String, reset: String) {
        let limitsValues = limits.components(separatedBy: "/")
        let resetValues = reset.components(separatedBy: "/")
        
        let count = limitsValues.count
        if count == 2 && count == resetValues.count {
            if let limitMax = UInt64(limitsValues[1]), let limitCurrent = UInt64(limitsValues[0]), let start = Int64(resetValues[0]), let end = Int64(resetValues[1]) {
                self.limit = APILimitValues(current: limitCurrent, max: limitMax)
                self.start = start
                self.end = end
                return
            }
        }
        return nil
    }
}

public class APIRateLimit: NSObject {
    public let limit: APIRequestCountValues
    public let remaining: APIRequestCountValues
    public let reset: APIResetValues
    
    init(limit: APIRequestCountValues, remaining: APIRequestCountValues, reset: APIResetValues) {
        self.limit = limit
        self.remaining = remaining
        self.reset = reset
    }
    
    init?(limit: String, remaining: String, reset: String) {
        let limitValues = limit.components(separatedBy: "/")
        let remainingValues = remaining.components(separatedBy: "/")
        let resetValues = reset.components(separatedBy: "/")
        
        let count = limitValues.count
        if count == 2 && count == remainingValues.count && count == resetValues.count {
            if let limitDaily = UInt64(limitValues[1]),
                let limitCurrent = UInt64(limitValues[0]),
                let remainingDaily = UInt64(remainingValues[1]),
                let remainingCurrent = UInt64(remainingValues[0]),
                let resetDaily = Int64(resetValues[1]),
                let resetCurrrent = Int64(resetValues[0]) {
                self.limit = APIRequestCountValues(slidingMinute: limitCurrent, daily: limitDaily)
                self.remaining = APIRequestCountValues(slidingMinute: remainingCurrent, daily: remainingDaily)
                self.reset = APIResetValues(slidingMinute: resetCurrrent, daily: resetDaily)
                return
            }
        }
        return nil
    }
}
