//
//  CouponExpirationNotificationUseCase.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/17/23.
//

import Foundation

final class CouponExpirationNotificationUseCase {
    private let store: DataStorable
    private let userNotificationCenter: UserNotificationCenterProtocol
    
    init(store: DataStorable, userNotificationCenter: UserNotificationCenterProtocol) {
        self.store = store
        self.userNotificationCenter = userNotificationCenter
    }
    
    public func requestNotificationAuthorizationIfNeeded() {
        userNotificationCenter.requestAuthorizationIfNeeded()
    }
    
    public func scheduleUpcomingExpirationNotifications() {
        store.value(key: .couponList, defaultValue: [CouponRepositoryItem]())
            .filter { !$0.expiresAt.expired }
            .forEach {
                scheduleExpirationNotifications(for: $0)
            }
    }
    
    public func updateBadgeCount() {
        userNotificationCenter.setApplicationIconBadgeNumber(store.value(key: .couponList, defaultValue: [CouponRepositoryItem]()).filter { $0.expiresAt.expiresIn(days: 7) }.count)
    }
    
    public func cancelAllScheduledNotifications() {
        userNotificationCenter.cancelAllNotifications()
    }
    
    private func scheduleExpirationNotifications(for coupon: CouponRepositoryItem) {
        userNotificationCenter.scheduleNotification(title: "7일 후에 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt.addingTimeInterval(24 * 3600 * -7))
        userNotificationCenter.scheduleNotification(title: "3일 후에 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt.addingTimeInterval(24 * 3600 * -3))
        userNotificationCenter.scheduleNotification(title: "오늘 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt)
    }
}
