//
//  CouponEditingViewController.swift
//  CouponBox
//
//  Created by Samuel Kim on 1/3/24.
//

import CouponBox_BusinessRules

struct CouponEditingViewController {
    private let couponEditingUseCase: CouponEditingUseCaseInputProtocol
    
    init(couponEditingUseCase: CouponEditingUseCaseInputProtocol) {
        self.couponEditingUseCase = couponEditingUseCase
    }
    
    func viewDidAppear() {
        couponEditingUseCase.loadView()
    }
    
    func couponDataDidChange(_ data: CouponEditingViewModel) {
        couponEditingUseCase.edit(data.toCoupon())
    }
    
    func cancelButtonDidTap() {
        couponEditingUseCase.cancel()
    }
    
    func doneButtonDidTap() {
        couponEditingUseCase.save()
    }
}
