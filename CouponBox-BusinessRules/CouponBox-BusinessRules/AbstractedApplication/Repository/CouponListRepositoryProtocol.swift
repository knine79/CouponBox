//
//  CouponListRepositoryProtocol.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/11/23.
//

import Combine

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
}

public protocol CouponListRepositoryProtocol {
    func fetchCouponList() throws -> [Coupon]
    func fetchCoupon(code: String) throws -> Coupon?
    func isExistCoupon(code: String) throws -> Bool
    func addCoupon(_ coupon: Coupon) throws
    func updateCoupon(_ coupon: Coupon) throws
    func removeCoupon(code: String) throws
}
