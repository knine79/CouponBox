//
//  FakeCouponListRepository.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import CouponBox_BusinessRules
import Combine

final class FakeCouponListRepository: CouponListRepositoryProtocol {
    private var coupons: [Coupon]
    public init(coupons: [Coupon] = []) {
        self.coupons = coupons
    }
    
    public func fetchCouponList() throws -> [Coupon] {
        coupons
    }
    
    public func isExistCoupon(code: String) throws -> Bool {
        coupons.contains(where: { $0.code == code })
    }
    
    func fetchCoupon(code: String) throws -> Coupon? {
        coupons.first(where: { $0.code == code })
    }
    
    public func addCoupon(_ coupon: Coupon) throws {
        coupons.append(coupon)
    }
    
    public func updateCoupon(_ coupon: Coupon) throws {
        coupons.removeAll(where: { $0.code == coupon.code })
        coupons.append(coupon)
    }
    
    public func removeCoupon(code: String) throws {
        coupons.removeAll(where: { $0.code == code })
    }
    
}
