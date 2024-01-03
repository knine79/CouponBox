//
//  CouponExpirationNotificationUseCase.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/17/23.
//

import Combine

public protocol CouponExpirationNotificationUseCaseInputProtocol {
    func requestNotificationAuthorizationIfNeeded()
    func scheduleUpcomingExpirationNotifications()
    func updateBadgeCount()
    func cancelAllScheduledNotifications()
    func loadExpirationNotificationTime()
    func saveExpirationNotificationTime()
}

public protocol CouponExpirationNotificationUseCaseOutputProtocol {
    func presentExpirationNotificationTime(_ value: Date)
}

public final class CouponExpirationNotificationUseCase: CouponExpirationNotificationUseCaseInputProtocol {
    private let presenter: CouponExpirationNotificationUseCaseOutputProtocol?
    private let repository: RepositoryContainerProtocol
    private let store: DataStorable
    private let userNotificationCenter: UserNotificationCenterProtocol
    
    private var cancellables = Set<AnyCancellable>()

    init(presenter: CouponExpirationNotificationUseCaseOutputProtocol? = nil,
         repository: RepositoryContainerProtocol,
         store: DataStorable,
         userNotificationCenter: UserNotificationCenterProtocol)
    {
        self.presenter = presenter
        self.repository = repository
        self.store = store
        self.userNotificationCenter = userNotificationCenter
        
        setupTrigger()
    }
    
    private func setupTrigger() {
        guard Thread.isMainThread else { return }
        
        store.valuePublisher(key: .expirationNotificationTime, typeOf: TimeInterval.self)
            .sink { [weak self] in
                self?.presenter?.presentExpirationNotificationTime(Date.localizedZero.addingTimeInterval($0 ?? 8 * 3600))
            }.store(in: &cancellables)
    }
    
    public func requestNotificationAuthorizationIfNeeded() {
        userNotificationCenter.requestAuthorizationIfNeeded()
    }
    
    public func scheduleUpcomingExpirationNotifications() {
        store.value(key: .couponList, defaultValue: [Coupon]())
            .filter { !$0.expired }
            .forEach {
                scheduleExpirationNotifications(for: $0)
            }
    }
    
    public func updateBadgeCount() {
        userNotificationCenter.setApplicationIconBadgeNumber(store.value(key: .couponList, defaultValue: [Coupon]()).filter { $0.dueToExpire }.count)
    }
    
    public func cancelAllScheduledNotifications() {
        userNotificationCenter.cancelAllNotifications()
    }
    
    public func loadExpirationNotificationTime() {
        store.update(key: .expirationNotificationTime, value: repository.settings.loadExpirationNotificationTime())
    }
    
    public func saveExpirationNotificationTime() {
        let timeInterval = Date.localizedZero.distance(to: store.value(key: .expirationNotificationTime, defaultValue: Date()))
        store.update(key: .expirationNotificationTime, value: timeInterval)
        repository.settings.saveExpirationNotificationTime(timeInterval)
    }
    
    private func scheduleExpirationNotifications(for coupon: Coupon) {
        let notificationTime = store.value(key: .expirationNotificationTime, typeOf: TimeInterval.self) ?? 8 * 3600
        userNotificationCenter.scheduleNotification(title: "7일 후에 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt.addingTimeInterval(24 * 3600 * -7).startOfDay.addingTimeInterval(notificationTime))
        userNotificationCenter.scheduleNotification(title: "3일 후에 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt.addingTimeInterval(24 * 3600 * -3).startOfDay.addingTimeInterval(notificationTime))
        userNotificationCenter.scheduleNotification(title: "오늘 만료되는 쿠폰이 있습니다.".locaized, body: coupon.name, at: coupon.expiresAt.startOfDay.addingTimeInterval(notificationTime))
    }
}
