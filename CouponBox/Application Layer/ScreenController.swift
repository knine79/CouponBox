//
//  ScreenController.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/19/23.
//

import UIKit

final class ScreenController: ScreenControllerProtocol {
    var brightness: CGFloat {
        UIScreen.main.brightness
    }
    
    func setBrightness(_ value: CGFloat) {
        UIScreen.main.brightness = value
    }
}
