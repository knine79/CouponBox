//
//  CouponEditingViewModel.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import Foundation

public final class CouponEditingViewModel: ObservableObject {
    @Published public var imageData: Data?
    @Published public var name: String = ""
    @Published public var shop: String = ""
    @Published public var expiresAt: Date = .init()
    @Published public var barcode: String = ""
    
    @Published public var recognizedTexts: [String] = []
    @Published public var loading: Bool = false
    @Published public var canDone: Bool = false
    
    var toVO: Coupon {
        Coupon(name: name, shop: shop, expiresAt: expiresAt, code: barcode, imageData: imageData ?? Data())
    }
}
