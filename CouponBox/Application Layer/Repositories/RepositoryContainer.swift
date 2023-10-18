//
//  RepositoryContainer.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import Foundation

final class RepositoryContainer: RepositoryContainerProtocol {
    var couponList: CouponListRepositoryProtocol {
        CouponListRepository()
    }
}
