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
    
    public func createCouponListUseCase(presenter: CouponListUseCaseOutputProtocol? = nil) -> CouponListUseCase {
        CouponListUseCase(presenter: presenter, repository: dependencies.repositoryContainer, store: dependencies.store)
    }
    
    public func createScreenBrightnessUseCase() -> ScreenBrightnessUseCase {
        ScreenBrightnessUseCase(store: dependencies.store, screenController: dependencies.screenController)
    }
    
    public func createCouponEditingUseCase(presenter: CouponEditingUseCaseOutputProtocol? = nil, couponImageData: Data, completionHandler: @escaping (_ isDone: Bool) -> Void = { _ in }) -> CouponEditingUseCase {
        CouponEditingUseCase(
            presenter: presenter,
            repository: dependencies.repositoryContainer,
            store: dependencies.store,
            imageAnalyzer: dependencies.imageAnalyzer,
            couponImageData: couponImageData,
            completionHandler: completionHandler
        )
    }
    
    public func createCouponEditingUseCase(presenter: CouponEditingUseCaseOutputProtocol? = nil, couponCode: String) -> CouponEditingUseCase {
        CouponEditingUseCase(
            presenter: presenter,
            repository: dependencies.repositoryContainer,
            store: dependencies.store,
            imageAnalyzer: dependencies.imageAnalyzer,
            couponCode: couponCode
        )
    }
    
    public func createCouponExpirationNotificationUseCase(presenter: CouponExpirationNotificationUseCaseOutputProtocol? = nil) -> CouponExpirationNotificationUseCase {
        
        CouponExpirationNotificationUseCase(
            presenter: presenter,
            repository: dependencies.repositoryContainer,
            store: dependencies.store,
            userNotificationCenter: dependencies.userNotificationCenter
        )
    }
}
