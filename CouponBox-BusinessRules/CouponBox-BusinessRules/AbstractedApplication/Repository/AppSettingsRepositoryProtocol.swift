//
//  AppSettingsRepositoryProtocol.swift
//  CouponBox-BusinessRules
//
//  Created by Samuel Kim on 11/2/23.
//

import Foundation

public protocol AppSettingsRepositoryProtocol {
    func loadExpirationNotificationTime() -> TimeInterval
    func saveExpirationNotificationTime(_ time: TimeInterval)
}
