//
//  UseCaseFactory.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import Foundation

struct UseCaseFactoryDependencies {
    let repositoryContainer: RepositoryContainerProtocol
    let store: DataStorable
    let imageAnalyzer: ImageAnalyzable
    let userNotificationCenter: UserNotificationCenterProtocol
    let application: ApplicationProtocol
}

final class UseCaseFactory {
    let dependencies: UseCaseFactoryDependencies
    init(dependencies: UseCaseFactoryDependencies) {
        self.dependencies = dependencies
    }
    
    func createCouponListUseCase() -> CouponListUseCase {
        CouponListUseCase(repository: dependencies.repositoryContainer.couponList, store: dependencies.store)
    }
    
    func createCouponEditingUseCase(couponImageData: Data) -> CouponEditingUseCase {
        CouponEditingUseCase(
            couponImageData: couponImageData,
            repository: dependencies.repositoryContainer.couponList,
            store: dependencies.store,
            imageAnalyzer: dependencies.imageAnalyzer
        )
    }
    
    func createCouponEditingUseCase(couponCode: String) -> CouponEditingUseCase {
        CouponEditingUseCase(
            couponCode: couponCode,
            repository: dependencies.repositoryContainer.couponList,
            store: dependencies.store,
            imageAnalyzer: dependencies.imageAnalyzer
        )
    }
    
    func createCouponExpirationNotificationUseCase() -> CouponExpirationNotificationUseCase {
        CouponExpirationNotificationUseCase(store: dependencies.store, userNotificationCenter: dependencies.userNotificationCenter, application: dependencies.application)
    }
}
