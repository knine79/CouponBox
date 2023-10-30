//
//  Stubs.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/19/23.
//

import CouponBox_BusinessRules

public struct Stubs {
    public static let useCaseFactory: UseCaseFactory = {
        let useCaseFactoryDependencies = UseCaseFactoryDependencies(
            repositoryContainer: FakeRepositoryContainer(),
            store: DataStore(),
            imageAnalyzer: ImageAnalyzer(),
            userNotificationCenter: UserNotificationCenter(),
            screenController: ScreenController()
        )
        
        return UseCaseFactory(dependencies: useCaseFactoryDependencies)
    }()
    
    public static func useCaseFactory(spyRepository: SpyRepositoryContainer) -> UseCaseFactory {
        let useCaseFactoryDependencies = UseCaseFactoryDependencies(
            repositoryContainer: spyRepository,
            store: DataStore(),
            imageAnalyzer: ImageAnalyzer(),
            userNotificationCenter: UserNotificationCenter(),
            screenController: ScreenController()
        )
        
        return UseCaseFactory(dependencies: useCaseFactoryDependencies)
    }
}

public final class FakeRepositoryContainer: RepositoryContainerProtocol {
    public var couponList: CouponListRepositoryProtocol! {
        FakeCouponListRepository()
    }
    
    public var settings: AppSettingsRepositoryProtocol! {
        FakeAppSettingsRepository()
    }
}

public final class SpyRepositoryContainer: RepositoryContainerProtocol {
    public var couponList: CouponListRepositoryProtocol!
    public var settings: AppSettingsRepositoryProtocol!
    public init() {}
}
