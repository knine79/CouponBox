//
//  CouponBoxApp.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import SwiftUI
//import BackgroundTasks

@main
struct CouponBoxApp: App {
    @Environment(\.scenePhase) private var phase
    
    let useCaseFactory: UseCaseFactory = {
        let useCaseFactoryDependencies = UseCaseFactoryDependencies(
            repositoryContainer: RepositoryContainer(),
            store: DataStore(),
            imageAnalyzer: ImageAnalyzer(),
            userNotificationCenter: UserNotificationCenter(),
            application: Application()
        )
    
        return UseCaseFactory(dependencies: useCaseFactoryDependencies)
    }()
    
    var couponExpirationNotificationUseCase: CouponExpirationNotificationUseCase {
        useCaseFactory.createCouponExpirationNotificationUseCase()
    }
    
    var body: some Scene {
        WindowGroup {
            let viewFactoryDependencies = ViewFactoryDependencies(useCaseFactory: useCaseFactory)
            let viewFactory = ViewFactory(dependencies: viewFactoryDependencies)
            viewFactory.createCouponListView()
                .environmentObject(viewFactory)
        }
        .onChange(of: phase) { oldValue, newValue in
            switch newValue {
            case .inactive:
                rescheduleUpcomingExpirationNotifications()
                couponExpirationNotificationUseCase.updateBadgeCount()
                
            case .active:
                couponExpirationNotificationUseCase.requestNotificationAuthorizationIfNeeded()
//                cancelAllBackgroundTasks()
//                couponExpirationNotificationUseCase.cancelAllScheduledNotifications()
            default: break
            }
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { printLog($0.map { $0.identifier}) })
        }
//        .backgroundTask(.appRefresh("com.samuel.CouponBox.notification.add")) {
//            doBackgroundTask()
//        }
    }
    
    private func rescheduleUpcomingExpirationNotifications() {
        couponExpirationNotificationUseCase.cancelAllScheduledNotifications()
        useCaseFactory.createCouponListUseCase().fetchCouponList()
//        UserNotificationCenter().scheduleNotification(title: "테스트", body: "백그라운드 태스크 실행됨", at: .now.addingTimeInterval(1))
        couponExpirationNotificationUseCase.scheduleUpcomingExpirationNotifications()
    }
    
//    private func scheduleNextBackgroundTask() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.samuel.CouponBox.notification.add")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 6 * 3600)
//        try? BGTaskScheduler.shared.submit(request)
//    }
//    
//    private func cancelAllBackgroundTasks() {
//        BGTaskScheduler.shared.cancelAllTaskRequests()
//    }
}
