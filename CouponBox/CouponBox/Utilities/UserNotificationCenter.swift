//
//  UserNotificationCenter.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/17/23.
//

import CouponBox_BusinessRules
import UserNotifications

public final class UserNotificationCenter: UserNotificationCenterProtocol {
    public init() {}
    
    let center = UNUserNotificationCenter.current()
    
    public func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { [weak self] settings in
            guard let self, (settings.authorizationStatus != .authorized) else { return }
            
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if let error = error {
                    printLog(error.localizedDescription)
                }
            }
        }
    }
    
    public func scheduleNotification(title: String, body: String, at date: Date?) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        var trigger: UNNotificationTrigger? = nil
        if let date {
            let timeInterval = Date().distance(to: date)
            guard timeInterval > 0 else { return }
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
        
    }
    
    public func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    public func setApplicationIconBadgeNumber(_ value: Int) {
        center.setBadgeCount(value)
    }
}
