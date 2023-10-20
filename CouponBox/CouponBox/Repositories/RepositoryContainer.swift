//
//  RepositoryContainer.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import CouponBox_BusinessRules

public final class RepositoryContainer: RepositoryContainerProtocol {
    let persistenceController: PersistenceController
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }
    
    public var couponList: CouponListRepositoryProtocol! {
        CouponListRepository(container: persistenceController.container)
    }
}
