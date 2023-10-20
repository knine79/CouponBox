//
//  FakeCouponListRepository.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import CouponBox_BusinessRules

final class FakeCouponListRepository: CouponListRepositoryProtocol {
    private var coupons: [Coupon]
    init(coupons: [Coupon] = []) {
        self.coupons = coupons
    }
    
    func fetchCouponList() throws -> [Coupon] {
        coupons
    }

    func fetchCoupon(code: String) throws -> Coupon? {
        coupons.first(where: { $0.code == code })
    }
    
    func isExistCoupon(code: String) throws -> Bool {
        coupons.contains(where: { $0.code == code })
    }
    
    func addCoupon(_ coupon: Coupon) throws {
        coupons.append(coupon)
    }
    
    func updateCoupon(_ coupon: Coupon) throws {
        coupons.removeAll(where: { $0.code == coupon.code })
        coupons.append(coupon)
    }
    
    func removeCoupon(code: String) throws {
        coupons.removeAll(where: { $0.code == code })
    }
    
}
