//
//  CouponListUseCase.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import Foundation
import Combine

public protocol CouponListPresentable {
    var viewModel: CouponListViewModel { get }
}

public protocol CouponListControllable {
    func fetchCouponList()
    func removeCoupon(code: String)
}

public final class CouponListUseCase: CouponListPresentable, CouponListControllable {
    private let repository: CouponListRepositoryProtocol
    private let store: DataStorable
    
    public var viewModel = CouponListViewModel()
    private var cancellables = Set<AnyCancellable>()

    init(repository: CouponListRepositoryProtocol, store: DataStorable) {
        self.repository = repository
        self.store = store
        
        setupTrigger()
    }
    
    private func setupTrigger() {
        guard Thread.isMainThread else { return }
        store.valuePublisher(key: .couponList, typeOf: [CouponRepositoryItem].self)
            .sink { [weak self] coupons in
                self?.viewModel.coupons = coupons?.map { CouponVO(couponRepositoryItem: $0) } ?? []
                self?.viewModel.loading = false
            }.store(in: &cancellables)
    }
    
    public func fetchCouponList() {
        if Thread.isMainThread {
            viewModel.loading = true
        }
        store.update(key: .couponList, value: (try? repository.fetchCouponList()) ?? [])
    }
    
    public func removeCoupon(code: String) {
        try? repository.removeCoupon(code: code)
        store.patch(key: .couponList) {
            var value: [CouponRepositoryItem] = $0 ?? []
            value.removeAll(where: { $0.code == code})
            return value
        }
    }
}
