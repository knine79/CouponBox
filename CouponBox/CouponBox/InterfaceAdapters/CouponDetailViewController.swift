//
//  CouponDetailViewController.swift
//  CouponBox
//
//  Created by Samuel Kim on 1/5/24.
//

import CouponBox_BusinessRules

struct CouponDetailViewController {
    private let screenBrightnessUseCase: ScreenBrightnessUseCaseInputProtocol
    
    init(screenBrightnessUseCase: ScreenBrightnessUseCaseInputProtocol) {
        self.screenBrightnessUseCase = screenBrightnessUseCase
    }
    
    func maximizeBrightness() {
        screenBrightnessUseCase.maximizeBrightness()
    }
    
    func rollbackBrightness() {
        screenBrightnessUseCase.rollbackBrightness()
    }
}
