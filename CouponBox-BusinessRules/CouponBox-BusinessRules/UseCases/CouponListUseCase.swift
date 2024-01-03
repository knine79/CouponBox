//
//  CouponListUseCase.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import Foundation
import Combine

public protocol CouponListUseCaseInputProtocol {
    func fetchCouponList()
    func removeCoupon(code: String)
}

public protocol CouponListUseCaseOutputProtocol {
    func presentCouponList(expiredCoupons: [Coupon], dueToExpireCoupons: [Coupon], restCoupons: [Coupon])
    func presentProgress(isLoading: Bool)
}

public final class CouponListUseCase: CouponListUseCaseInputProtocol {
    private let presenter: CouponListUseCaseOutputProtocol?
    private let repository: RepositoryContainerProtocol
    private let store: DataStorable
    
    private var cancellables = Set<AnyCancellable>()

    init(presenter: CouponListUseCaseOutputProtocol?, repository: RepositoryContainerProtocol, store: DataStorable) {
        self.presenter = presenter
        self.repository = repository
        self.store = store
        
        setupTrigger()
    }
    
    private func setupTrigger() {
        guard Thread.isMainThread else { return }
        
        store.valuePublisher(key: .couponList, typeOf: [Coupon].self)
            .sink { [weak self] in
                let coupons = $0 ?? []
                self?.presenter?.presentCouponList(
                    expiredCoupons: coupons.filter {
                        $0.expired
                    },
                    dueToExpireCoupons: coupons.filter {
                        $0.dueToExpire
                    },
                    restCoupons: coupons.filter {
                        !$0.expiredOrDueToExpire
                    }
                )
                self?.presenter?.presentProgress(isLoading: false)
            }.store(in: &cancellables)
    }
    
    public func fetchCouponList() {
        if Thread.isMainThread {
            presenter?.presentProgress(isLoading: true)
        }
        if let coupons = try? repository.couponList.fetchCouponList() {
            store.update(key: .couponList, value: coupons)
        }
    }
    
    public func removeCoupon(code: String) {
        try? repository.couponList.removeCoupon(code: code)
        store.patch(key: .couponList) {
            var value: [Coupon] = $0 ?? []
            value.removeAll(where: { $0.code == code})
            return value
        }
    }
}
