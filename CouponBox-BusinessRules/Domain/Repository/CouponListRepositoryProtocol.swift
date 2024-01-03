//
//  CouponListRepositoryProtocol.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/11/23.
//

import Foundation

public protocol CouponListRepositoryProtocol {
    func fetchCouponList() throws -> [Coupon]
    func fetchCoupon(code: String) throws -> Coupon?
    func isExistCoupon(code: String) throws -> Bool
    func addCoupon(_ coupon: Coupon) throws
    func updateCoupon(_ coupon: Coupon) throws
    func removeCoupon(code: String) throws
}
