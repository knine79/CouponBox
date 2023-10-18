//
//  CouponListViewModel.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/10/23.
//

import Foundation

public class CouponListViewModel: ObservableObject {
    @Published var coupons: [CouponRepositoryItem] = []
    @Published var loading = false
}
