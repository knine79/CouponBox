//
//  CouponEditingViewModel.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import CouponBox_BusinessRules

public final class CouponEditingViewModel: ObservableObject {
    @Published public var imageData: Data?
    @Published public var name: String = ""
    @Published public var shop: String = ""
    @Published public var expiresAt: Date = .init()
    @Published public var barcode: String = ""
    
    @Published public var recognizedTexts: [String] = []
    @Published public var loading: Bool = false
    @Published public var canDone: Bool = false
    @Published public var alreadyExistWarningDisplayed: Bool = false
    
    var expired = false
    var expirationDescription = ""
    var expiredOrDueToExpire = false
    
    func toCoupon() -> Coupon {
        Coupon(name: name, shop: shop, expiresAt: expiresAt, code: barcode, imageData: imageData ?? Data())
    }
}

extension CouponEditingViewModel: Equatable {
    public static func == (lhs: CouponEditingViewModel, rhs: CouponEditingViewModel) -> Bool {
        lhs.imageData == rhs.imageData
        && lhs.name == rhs.name
        && lhs.shop == rhs.shop
        && lhs.expiresAt == rhs.expiresAt
        && lhs.barcode == rhs.barcode
    }
}
