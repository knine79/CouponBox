//
//  CouponViewModel.swift
//  CouponBox
//
//  Created by Samuel Kim on 1/5/24.
//

import CouponBox_BusinessRules

struct CouponViewModel: Hashable {
    let name: String
    let shop: String
    let code: String
    let imageData: Data
    let expired: Bool
    let expirationDescription: String
    let expiredOrDueToExpire: Bool
    
    init(from coupon: Coupon) {
        name = coupon.name
        shop = coupon.shop
        code = coupon.code
        imageData = coupon.imageData
        expired = coupon.expired
        expirationDescription = "\(coupon.expiresAt.formatted(date: .long, time: .none)) \(coupon.expired ? "(만료됨)".locaized : String(format: "(%@ 만료예정)".locaized, coupon.expiresAt.relativeTime))"
        expiredOrDueToExpire = coupon.expiredOrDueToExpire
    }
}
