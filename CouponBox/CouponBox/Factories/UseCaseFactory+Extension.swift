//
//  UseCaseFactory+Extension.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/30/23.
//

import CouponBox_BusinessRules

extension UseCaseFactory {
    public static func create() -> UseCaseFactory {
        let useCaseFactoryDependencies = UseCaseFactoryDependencies(
            repositoryContainer: RepositoryContainer(persistentContainer: PersistentContainer.default, cache: Cache()),
            store: DataStore(),
            imageAnalyzer: ImageAnalyzer(),
            userNotificationCenter: UserNotificationCenter(),
            screenController: ScreenController()
        )
        
        return UseCaseFactory(dependencies: useCaseFactoryDependencies)
    }
}
