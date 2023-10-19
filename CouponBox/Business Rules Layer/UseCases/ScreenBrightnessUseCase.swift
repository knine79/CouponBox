//
//  ScreenBrightnessUseCase.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/19/23.
//

import Foundation

public protocol ScreenBrightnessControllable {
    func maximizeBrightness()
    func rollbackBrightness()
}

public final class ScreenBrightnessUseCase: ScreenBrightnessControllable {

    private let store: DataStorable
    private let screenController: ScreenControllerProtocol
    init(store: DataStorable, screenController: ScreenControllerProtocol) {
        self.store = store
        self.screenController = screenController
    }
    
    public func maximizeBrightness() {
        guard store.value(key: .legacyScreenBrightness, typeOf: CGFloat.self) == nil else { return }
        store.update(key: .legacyScreenBrightness, value: screenController.brightness)
        screenController.setBrightness(1)
    }
    
    public func rollbackBrightness() {
        guard let value = store.value(key: .legacyScreenBrightness, typeOf: CGFloat.self) else { return }
        store.update(key: .legacyScreenBrightness, value: nil)
        screenController.setBrightness(value)
    }
}
