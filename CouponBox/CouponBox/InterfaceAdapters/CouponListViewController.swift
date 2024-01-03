//
//  CouponListViewController.swift
//  CouponBox
//
//  Created by Samuel Kim on 12/22/23.
//

import CouponBox_BusinessRules

struct CouponListViewController {
    private let couponListUseCase: CouponListUseCaseInputProtocol
    private let couponExpirationNotificationUseCase: CouponExpirationNotificationUseCaseInputProtocol
    
    init(couponListUseCase: CouponListUseCaseInputProtocol, couponExpirationNotificationUseCase: CouponExpirationNotificationUseCaseInputProtocol) {
        self.couponListUseCase = couponListUseCase
        self.couponExpirationNotificationUseCase = couponExpirationNotificationUseCase
    }
    
    func viewDidAppear() {
        couponListUseCase.fetchCouponList()
    }
    
    func viewDidReturnFromDetailView() {
        couponListUseCase.fetchCouponList()
    }
    
    func couponDidRemove(code: String) {
        couponListUseCase.removeCoupon(code: code)
    }

    func settingViewDidAppear() {
        couponExpirationNotificationUseCase.loadExpirationNotificationTime()
    }
    
    func saveButtonOnSettingViewDidTap() {
        couponExpirationNotificationUseCase.saveExpirationNotificationTime()
    }
}
