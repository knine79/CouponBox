//
//  Stubs+Extension.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/30/23.
//

import Foundation

extension Stubs {
    public static let viewFactory: ViewFactory = {
        let viewFactoryDependencies = ViewFactoryDependencies(useCaseFactory: useCaseFactory)
        return ViewFactory(dependencies: viewFactoryDependencies)
    }()
}
