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
    
    func createCouponListView() -> CouponListView {
        let useCase = dependencies.useCaseFactory.createCouponListUseCase()
        return CouponListView(presenter: useCase, controller: useCase)
    }
    
    func createCouponDetailView(coupon: CouponVO) -> CouponDetailView {
        let useCase = dependencies.useCaseFactory.createScreenBrightnessUseCase()
        return CouponDetailView(coupon: coupon, screenBrightnessController: useCase)
    }
    
    func createCouponEditingView(couponImageData: Data) -> CouponEditingView {
        let useCase = dependencies.useCaseFactory.createCouponEditingUseCase(couponImageData: couponImageData)
        return CouponEditingView(presenter: useCase, controller: useCase)
    }
    
    func createCouponEditingView(couponCode: String) -> CouponEditingView {
        let useCase = dependencies.useCaseFactory.createCouponEditingUseCase(couponCode: couponCode)
        return CouponEditingView(presenter: useCase, controller: useCase)
    }
}
