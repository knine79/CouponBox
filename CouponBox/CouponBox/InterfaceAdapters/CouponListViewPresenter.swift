//
//  CouponListViewPresenter.swift
//  CouponBox
//
//  Created by Samuel Kim on 12/22/23.
//

import CouponBox_BusinessRules

struct CouponListViewPresenter: CouponListUseCaseOutputProtocol, CouponExpirationNotificationUseCaseOutputProtocol {
    var viewModel = CouponListViewModel()
    
    func presentCouponList(expiredCoupons: [Coupon], dueToExpireCoupons: [Coupon], restCoupons: [Coupon]) {
        viewModel.isEmpty = expiredCoupons.isEmpty && dueToExpireCoupons.isEmpty && restCoupons.isEmpty
        viewModel.expiredCoupons = expiredCoupons.map { .init(from: $0) }
        viewModel.dueToExpireCoupons = dueToExpireCoupons.map { .init(from: $0) }
        viewModel.notDueToExpireCoupons = restCoupons.map { .init(from: $0) }
    }
    
    func presentProgress(isLoading: Bool) {
        viewModel.loading = isLoading
    }
    
    func presentExpirationNotificationTime(_ value: Date) {
        viewModel.expirationNotificationTime = value
    }
}
