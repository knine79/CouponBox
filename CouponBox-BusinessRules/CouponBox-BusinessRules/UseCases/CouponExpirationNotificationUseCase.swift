//
//  CouponExpirationNotificationUseCase.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/17/23.
//

import Foundation

public final class CouponExpirationNotificationUseCase {
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
        store.value(key: .couponList, defaultValue: [Coupon]())
            .filter { !$0.expiresAt.expired }
            .forEach {
                scheduleExpirationNotifications(for: $0)
            }
    }
    
    public func updateBadgeCount() {
        userNotificationCenter.setApplicationIconBadgeNumber(store.value(key: .couponList, defaultValue: [Coupon]()).filter { $0.expiresAt.expiresIn(days: 7) }.count)
    }
    
    public func cancelAllScheduledNotifications() {
        userNotificationCenter.cancelAllNotifications()
    }
    
    private func scheduleExpirationNotifications(for coupon: Coupon) {
        let notificationTime = store.value(key: .expirationNotificationTime, typeOf: TimeInterval.self) ?? 7 * 3600
        userNotificationCenter.scheduleNotification(title: "7일 후에 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt.addingTimeInterval(24 * 3600 * -7).startOfDay.addingTimeInterval(notificationTime))
        userNotificationCenter.scheduleNotification(title: "3일 후에 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt.addingTimeInterval(24 * 3600 * -3).startOfDay.addingTimeInterval(notificationTime))
        userNotificationCenter.scheduleNotification(title: "오늘 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt.startOfDay.addingTimeInterval(notificationTime))
    }
}
