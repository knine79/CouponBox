//
//  CouponVO.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/19/23.
//

import Foundation

public struct CouponVO: Hashable {
    let name: String
    let expiresAt: Date
    let code: String
    let imageData: Data
    
    init(name: String, expiresAt: Date, code: String, imageData: Data) {
        self.name = name
        self.expiresAt = expiresAt
        self.code = code
        self.imageData = imageData
    }
    
    init(couponRepositoryItem: CouponRepositoryItem) {
        self.init(name: couponRepositoryItem.name,
                  expiresAt: couponRepositoryItem.expiresAt,
                  code: couponRepositoryItem.code,
                  imageData: couponRepositoryItem.imageData)
    }
}
