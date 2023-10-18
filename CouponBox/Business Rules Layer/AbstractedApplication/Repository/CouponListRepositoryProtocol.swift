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

public struct CouponRepositoryItem: Hashable {
    public var name: String
    public var expiresAt: Date
    public var code: String
    public var imageData: Data
}

public protocol CouponListRepositoryProtocol {
    func fetchCouponList() throws -> [CouponRepositoryItem]
    func fetchCoupon(code: String) throws -> CouponRepositoryItem?
    func isExistCoupon(code: String) throws -> Bool
    func addCoupon(_ coupon: CouponRepositoryItem) throws
    func updateCoupon(_ coupon: CouponRepositoryItem) throws
    func removeCoupon(code: String) throws
}
