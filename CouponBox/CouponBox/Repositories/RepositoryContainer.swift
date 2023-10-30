//
//  RepositoryContainer.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import CouponBox_BusinessRules
import CoreData

public final class RepositoryContainer: RepositoryContainerProtocol {
    private let persistentContainer: NSPersistentContainer
    private let cache: Cache
    public init(persistentContainer: NSPersistentContainer, cache: Cache) {
        self.persistentContainer = persistentContainer
        self.cache = cache
    }
    
    public var couponList: CouponListRepositoryProtocol! {
        CouponListRepository(container: persistentContainer)
    }
    
    public var settings: AppSettingsRepositoryProtocol! {
        AppSettingsRepository(cache: cache)
    }
}
