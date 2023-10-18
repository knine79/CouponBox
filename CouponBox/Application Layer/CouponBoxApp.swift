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
            default: break
            }
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { printLog($0.map { $0.identifier}) })
        }
    }
    
    private func rescheduleUpcomingExpirationNotifications() {
        couponExpirationNotificationUseCase.cancelAllScheduledNotifications()
        useCaseFactory.createCouponListUseCase().fetchCouponList()
        couponExpirationNotificationUseCase.scheduleUpcomingExpirationNotifications()
    }
}
