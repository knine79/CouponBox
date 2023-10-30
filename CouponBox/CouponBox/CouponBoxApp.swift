//
//  CouponBoxApp.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import SwiftUI
import CouponBox_BusinessRules

@main
struct CouponBoxApp: App {
    @Environment(\.scenePhase) private var phase
    
    let useCaseFactory: UseCaseFactory = {
        UseCaseFactory.create()
    }()
    
    var couponExpirationNotificationUseCase: CouponExpirationNotificationUseCase {
        useCaseFactory.createCouponExpirationNotificationUseCase()
    }
    
    var body: some Scene {
        WindowGroup {
            let viewFactory = ViewFactory.create(useCaseFactory: useCaseFactory)
            viewFactory.createCouponListView()
                .environmentObject(viewFactory)
        }
        .onChange(of: phase) { oldValue, newValue in
            switch newValue {
            case .inactive:
                rescheduleUpcomingExpirationNotifications()
                couponExpirationNotificationUseCase.updateBadgeCount()
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { printLog($0.map { $0.identifier}) })
                
            case .active:
                couponExpirationNotificationUseCase.requestNotificationAuthorizationIfNeeded()
            default: break
            }
        }
    }
    
    private func rescheduleUpcomingExpirationNotifications() {
        couponExpirationNotificationUseCase.cancelAllScheduledNotifications()
        useCaseFactory.createCouponListUseCase().fetchCouponList()
        couponExpirationNotificationUseCase.scheduleUpcomingExpirationNotifications()
    }
}
