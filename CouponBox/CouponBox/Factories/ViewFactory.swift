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
        let presenter = CouponListViewPresenter()
        let couponListUseCase = dependencies.useCaseFactory.createCouponListUseCase(presenter: presenter)
        let couponExpirationNotificationUseCase = dependencies.useCaseFactory.createCouponExpirationNotificationUseCase(presenter: presenter)
        let controller = CouponListViewController(
            couponListUseCase: couponListUseCase,
            couponExpirationNotificationUseCase: couponExpirationNotificationUseCase
        )
        return CouponListView(viewModel: presenter.viewModel, controller: controller)
    }
    
    func createCouponDetailView(coupon: CouponViewModel) -> CouponDetailView {
        let useCase = dependencies.useCaseFactory.createScreenBrightnessUseCase()
        let controller = CouponDetailViewController(screenBrightnessUseCase: useCase)
        return CouponDetailView(viewModel: coupon, controller: controller)
    }
    
    func createCouponEditingView(couponImageData: Data, completionHandler: @escaping (_ isDone: Bool) -> Void = { _ in }) -> CouponEditingView {
        let presenter = CouponEditingViewPresenter()
        let useCase = dependencies.useCaseFactory.createCouponEditingUseCase(presenter: presenter, couponImageData: couponImageData, completionHandler: completionHandler)
        let controller = CouponEditingViewController(couponEditingUseCase: useCase)
        return CouponEditingView(viewModel: presenter.viewModel, controller: controller)
    }
    
    func createCouponEditingView(couponCode: String) -> CouponEditingView {
        let presenter = CouponEditingViewPresenter()
        let useCase = dependencies.useCaseFactory.createCouponEditingUseCase(presenter: presenter, couponCode: couponCode)
        let controller = CouponEditingViewController(couponEditingUseCase: useCase)
        return CouponEditingView(viewModel: presenter.viewModel, controller: controller)
    }
}

extension ViewFactory {
    public static func create(useCaseFactory: UseCaseFactory) -> ViewFactory {
        let viewFactoryDependencies = ViewFactoryDependencies(useCaseFactory: useCaseFactory)
        return ViewFactory(dependencies: viewFactoryDependencies)
    }
}
