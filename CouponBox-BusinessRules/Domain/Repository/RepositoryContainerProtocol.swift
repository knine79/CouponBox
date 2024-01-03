//
//  RepositoryContainerProtocol.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import Foundation

public protocol RepositoryContainerProtocol {
    var couponList: CouponListRepositoryProtocol! { get }
    var settings: AppSettingsRepositoryProtocol! { get }
}
