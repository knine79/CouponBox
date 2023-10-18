//
//  FakeCouponListRepository.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import Foundation

final class FakeCouponListRepository: CouponListRepositoryProtocol {
    private var coupons: [CouponRepositoryItem]
    init(coupons: [CouponRepositoryItem] = []) {
        self.coupons = coupons
    }
    
    func fetchCouponList() throws -> [CouponRepositoryItem] {
        coupons
    }

    func fetchCoupon(code: String) throws -> CouponRepositoryItem? {
        coupons.first(where: { $0.code == code })
    }
    
    func isExistCoupon(code: String) throws -> Bool {
        coupons.contains(where: { $0.code == code })
    }
    
    func addCoupon(_ coupon: CouponRepositoryItem) throws {
        coupons.append(coupon)
    }
    
    func updateCoupon(_ coupon: CouponRepositoryItem) throws {
        coupons.removeAll(where: { $0.code == coupon.code })
        coupons.append(coupon)
    }
    
    func removeCoupon(code: String) throws {
        coupons.removeAll(where: { $0.code == code })
    }
    
}
