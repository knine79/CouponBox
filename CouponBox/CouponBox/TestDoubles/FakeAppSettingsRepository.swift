//
//  FakeAppSettingsRepository.swift
//  CouponBox
//
//  Created by Samuel Kim on 11/2/23.
//

import CouponBox_BusinessRules

final class FakeAppSettingsRepository: AppSettingsRepositoryProtocol {
    private var expirationNotificationTime: TimeInterval = 7 * 3600
    
    init() {}
    
    func loadExpirationNotificationTime() -> TimeInterval {
        expirationNotificationTime
    }
    
    func saveExpirationNotificationTime(_ time: TimeInterval) {
        expirationNotificationTime = time
    }
}
