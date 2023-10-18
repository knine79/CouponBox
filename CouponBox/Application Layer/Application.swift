//
//  Application.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/18/23.
//

import UIKit

class Application: ApplicationProtocol {
    func setApplicationIconBadgeNumber(_ value: Int) {
        UIApplication.shared.applicationIconBadgeNumber = value
    }
}
