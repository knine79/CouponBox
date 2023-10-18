//
//  ViewFactory.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import Foundation
import SwiftUI

struct ViewFactoryDependencies {
    let useCaseFactory: UseCaseFactory
}

final class ViewFactory: ObservableObject {
    let dependencies: ViewFactoryDependencies
    init(dependencies: ViewFactoryDependencies) {
        self.dependencies = dependencies
    }
    
    func createCouponEditingView(couponImageData: Data) -> CouponEditingView {
        let useCase = dependencies.useCaseFactory.createCouponEditingUseCase(couponImageData: couponImageData)
        return CouponEditingView(presenter: useCase, controller: useCase)
    }
    
    func createCouponEditingView(couponCode: String) -> CouponEditingView {
        let useCase = dependencies.useCaseFactory.createCouponEditingUseCase(couponCode: couponCode)
        return CouponEditingView(presenter: useCase, controller: useCase)
    }
    
    func createCouponListView() -> CouponListView {
        let useCase = dependencies.useCaseFactory.createCouponListUseCase()
        return CouponListView(presenter: useCase, controller: useCase)
    }
}
