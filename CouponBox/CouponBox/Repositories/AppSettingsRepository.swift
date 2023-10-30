//
//  AppSettingsRepository.swift
//  CouponBox
//
//  Created by Samuel Kim on 11/2/23.
//

import CouponBox_BusinessRules

final class AppSettingsRepository: AppSettingsRepositoryProtocol {
    let cache: Cache
    init(cache: Cache) {
        self.cache = cache
    }
    
    func loadExpirationNotificationTime() -> TimeInterval {
        cache.expirationNotificationTime
    }
    
    func saveExpirationNotificationTime(_ time: TimeInterval) {
        cache.expirationNotificationTime = time
    }
}
