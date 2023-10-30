//
//  ScreenController.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/19/23.
//

import CouponBox_BusinessRules
import UIKit

public final class ScreenController: ScreenControllerProtocol {
    public init() {}
    
    public var brightness: CGFloat {
        UIScreen.main.brightness
    }
    
    public func setBrightness(_ value: CGFloat) {
        UIScreen.main.brightness = value
    }
}
