//
//  UserNotificationCenter.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/17/23.
//

import Foundation
import UserNotifications

final class UserNotificationCenter: UserNotificationCenterProtocol {
    let center = UNUserNotificationCenter.current()
    
    func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { [weak self] settings in
            guard let self, (settings.authorizationStatus != .authorized) else { return }
            
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                if let error = error {
                    printLog(error.localizedDescription)
                }
            }
        }
    }
    
    func scheduleNotification(title: String, body: String, at date: Date?) {
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
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }
    
    func setApplicationIconBadgeNumber(_ value: Int) {
        center.setBadgeCount(value)
    }
}
