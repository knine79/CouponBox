//
//  UseCaseFactory.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import Foundation

public struct UseCaseFactoryDependencies {
    let repositoryContainer: RepositoryContainerProtocol
    let store: DataStorable
    let imageAnalyzer: ImageAnalyzable
    let userNotificationCenter: UserNotificationCenterProtocol
    let screenController: ScreenControllerProtocol
    
    public init(repositoryContainer: RepositoryContainerProtocol, store: DataStorable, imageAnalyzer: ImageAnalyzable, userNotificationCenter: UserNotificationCenterProtocol, screenController: ScreenControllerProtocol) {
        self.repositoryContainer = repositoryContainer
        self.store = store
        self.imageAnalyzer = imageAnalyzer
        self.userNotificationCenter = userNotificationCenter
        self.screenController = screenController
    }
}

public final class UseCaseFactory {
    let dependencies: UseCaseFactoryDependencies
    public init(dependencies: UseCaseFactoryDependencies) {
        self.dependencies = dependencies
    }
    
    public func createCouponListUseCase() -> CouponListUseCase {
        CouponListUseCase(repository: dependencies.repositoryContainer.couponList, store: dependencies.store)
    }
    
    public func createScreenBrightnessUseCase() -> ScreenBrightnessUseCase {
        ScreenBrightnessUseCase(store: dependencies.store, screenController: dependencies.screenController)
    }
    
    public func createCouponEditingUseCase(couponImageData: Data) -> CouponEditingUseCase {
        CouponEditingUseCase(
            couponImageData: couponImageData,
            repository: dependencies.repositoryContainer.couponList,
            store: dependencies.store,
            imageAnalyzer: dependencies.imageAnalyzer
        )
    }
    
    public func createCouponEditingUseCase(couponCode: String) -> CouponEditingUseCase {
        CouponEditingUseCase(
            couponCode: couponCode,
            repository: dependencies.repositoryContainer.couponList,
            store: dependencies.store,
            imageAnalyzer: dependencies.imageAnalyzer
        )
    }
    
    public func createCouponExpirationNotificationUseCase() -> CouponExpirationNotificationUseCase {
        CouponExpirationNotificationUseCase(store: dependencies.store, userNotificationCenter: dependencies.userNotificationCenter)
    }
}
