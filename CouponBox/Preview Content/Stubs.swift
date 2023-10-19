//
//  Stubs.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/19/23.
//

import Foundation

struct Stubs {
    static let useCaseFactory: UseCaseFactory = {
        let useCaseFactoryDependencies = UseCaseFactoryDependencies(
            repositoryContainer: FakeRepositoryContainer(),
            store: DataStore(),
            imageAnalyzer: ImageAnalyzer(),
            userNotificationCenter: UserNotificationCenter(),
            screenController: ScreenController()
        )
        
        return UseCaseFactory(dependencies: useCaseFactoryDependencies)
    }()
    
    static let viewFactory: ViewFactory = {
        let viewFactoryDependencies = ViewFactoryDependencies(useCaseFactory: useCaseFactory)
        return ViewFactory(dependencies: viewFactoryDependencies)
    }()
}

final class FakeRepositoryContainer: RepositoryContainerProtocol {
    var couponList: CouponListRepositoryProtocol {
        FakeCouponListRepository()
    }
}
