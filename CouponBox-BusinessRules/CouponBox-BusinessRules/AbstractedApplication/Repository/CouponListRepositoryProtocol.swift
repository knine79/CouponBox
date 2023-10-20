//
//  CouponListRepositoryProtocol.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/11/23.
//

import Foundation

public enum RepositoryError: LocalizedError {
    case entityNotFoundError
    case alreadyExistItem
    case itemNotFound
    
    public var errorDescription: String? {
        switch self {
        case .entityNotFoundError:
            "데이터 테이블을 찾을 수 없습니다.".locaized
        case .alreadyExistItem:
            "이미 존재하는 데이터입니다.".locaized
        case .itemNotFound:
            "존재하지 않는 데이터입니다.".locaized
        }
    }
}

public struct Coupon: Hashable {
    public var name: String
    public var shop: String
    public var expiresAt: Date
    public var code: String
    public var imageData: Data
    
    public init(name: String, shop: String, expiresAt: Date, code: String, imageData: Data) {
        self.name = name
        self.shop = shop
        self.expiresAt = expiresAt
        self.code = code
        self.imageData = imageData
    }
}

public protocol CouponListRepositoryProtocol {
    func fetchCouponList() throws -> [Coupon]
    func fetchCoupon(code: String) throws -> Coupon?
    func isExistCoupon(code: String) throws -> Bool
    func addCoupon(_ coupon: Coupon) throws
    func updateCoupon(_ coupon: Coupon) throws
    func removeCoupon(code: String) throws
}
