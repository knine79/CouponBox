//
//  CouponListViewModel.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/10/23.
//

import Foundation

final class CouponListViewModel: ObservableObject {
    @Published var isEmpty = false
    @Published var notDueToExpireCoupons: [CouponViewModel] = []
    @Published var dueToExpireCoupons: [CouponViewModel] = []
    @Published var expiredCoupons: [CouponViewModel] = []
    @Published var expirationNotificationTime: Date = Date()
    @Published var loading = false
}
