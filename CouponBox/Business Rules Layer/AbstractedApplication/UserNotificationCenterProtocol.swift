//
//  UserNotificationCenterProtocol.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/17/23.
//

import Foundation

public protocol UserNotificationCenterProtocol {
    func requestAuthorizationIfNeeded()
    func scheduleNotification(title: String, body: String, at: Date?)
    func cancelAllNotifications()
}
