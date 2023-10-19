//
//  CouponListViewModel.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/10/23.
//

import Foundation

public final class CouponListViewModel: ObservableObject {
    @Published var coupons: [CouponVO] = []
    @Published var loading = false
}
