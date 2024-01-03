//
//  Coupon.swift
//  CouponBox-BusinessRules
//
//  Created by Samuel Kim on 12/22/23.
//

import Foundation

public struct Coupon: Hashable {
    public var name: String
    public var shop: String
    public var expiresAt: Date
    public var code: String
    public var imageData: Data
    
    public init(name: String, shop: String, expiresAt: Date, code: String, imageData: Data) {
        self.name = name
        self.shop = shop
        self.expiresAt = expiresAt
        self.code = code
        self.imageData = imageData
    }
    
    public var expired: Bool {
        expiresAt.expired
    }
    
    public var dueToExpire: Bool {
        expiresAt.expiresIn(days: 7)
    }
    
    public var expiredOrDueToExpire: Bool {
        expired || dueToExpire
    }
}

private extension Date {
    func expiresIn(days: Int) -> Bool {
        !expired && Date.endOfToday.distance(to: self.addingTimeInterval(1)) < TimeInterval(3600 * 24 * days)
    }
    
    var expired: Bool {
        Date.endOfToday.distance(to: self.addingTimeInterval(1)) <= 0
    }
    
    func expiredOrExpiresIn(days: Int) -> Bool {
        expired || expiresIn(days: days)
    }
}

