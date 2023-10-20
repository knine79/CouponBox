//
//  ScreenControllerProtocol.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/19/23.
//

import Foundation

public protocol ScreenControllerProtocol {
    var brightness: CGFloat { get }
    func setBrightness(_ value: CGFloat)
}
