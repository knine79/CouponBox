//
//  CouponEditingViewPresenter.swift
//  CouponBox
//
//  Created by Samuel Kim on 12/29/23.
//

import CouponBox_BusinessRules

struct CouponEditingViewPresenter: CouponEditingUseCaseOutputProtocol {
    let viewModel = CouponEditingViewModel()
    
    func presentCouponData(_ coupon: Coupon) {
        viewModel.name = coupon.name
        viewModel.shop = coupon.shop
        viewModel.barcode = coupon.code
        viewModel.imageData = coupon.imageData
        viewModel.expiresAt = coupon.expiresAt
        viewModel.expired = coupon.expired
    }
    
    func presentCouponValidation(_ coupon: Coupon) {
        viewModel.expiredOrDueToExpire = coupon.expiredOrDueToExpire
        viewModel.expirationDescription = "\(coupon.expired ? "만료됨".locaized : String(format: "%@ 만료예정".locaized, coupon.expiresAt.relativeTime))"
    }
    
    func presentRecognizedTexts(_ texts: [String]) {
        viewModel.recognizedTexts = texts
    }
    
    func presentDoneButton(canDone: Bool) {
        viewModel.canDone = canDone
    }
    
    func presentProgress(isLoading: Bool) {
        viewModel.loading = isLoading
    }
    
    func presentAlreadyExistWarning(_ show: Bool) {
        viewModel.alreadyExistWarningDisplayed = show
    }
}
