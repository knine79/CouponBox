//
//  ViewFactory.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import CouponBox_BusinessRules
import SwiftUI

public struct ViewFactoryDependencies {
    let useCaseFactory: UseCaseFactory
    
    public init(useCaseFactory: UseCaseFactory) {
        self.useCaseFactory = useCaseFactory
    }
}

public final class ViewFactory: ObservableObject {
    let dependencies: ViewFactoryDependencies
    public init(dependencies: ViewFactoryDependencies) {
        self.dependencies = dependencies
    }
    
    func createCouponListView() -> CouponListView {
        let useCase = dependencies.useCaseFactory.createCouponListUseCase()
        return CouponListView(presenter: useCase, controller: useCase)
    }
    
    func createCouponDetailView(coupon: Coupon) -> CouponDetailView {
        let useCase = dependencies.useCaseFactory.createScreenBrightnessUseCase()
        return CouponDetailView(coupon: coupon, screenBrightnessController: useCase)
    }
    
    func createCouponEditingView(couponImageData: Data, completionHandler: @escaping (_ isDone: Bool) -> Void = { _ in }) -> CouponEditingView {
        let useCase = dependencies.useCaseFactory.createCouponEditingUseCase(couponImageData: couponImageData, completionHandler: completionHandler)
        return CouponEditingView(presenter: useCase, controller: useCase)
    }
    
    func createCouponEditingView(couponCode: String) -> CouponEditingView {
        let useCase = dependencies.useCaseFactory.createCouponEditingUseCase(couponCode: couponCode)
        return CouponEditingView(presenter: useCase, controller: useCase)
    }
}

extension ViewFactory {
    public static func create(useCaseFactory: UseCaseFactory) -> ViewFactory {
        let viewFactoryDependencies = ViewFactoryDependencies(useCaseFactory: useCaseFactory)
        return ViewFactory(dependencies: viewFactoryDependencies)
    }
}
