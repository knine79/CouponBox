//
//  CouponListViewModel.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/10/23.
//

import Foundation

public final class CouponListViewModel: ObservableObject {
    @Published public var isEmpty = true
    @Published public var notSoonToExpireCoupons: [Coupon] = []
    @Published public var soonToExpireCoupons: [Coupon] = []
    @Published public var expiredCoupons: [Coupon] = []
    @Published public var notificationTime: Date = Date()
    @Published public var loading = false
}
