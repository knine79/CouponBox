//
//  Locale+Extension.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/19/23.
//

import Foundation

extension Locale {
    public static let preferred: Locale = {
        Locale(identifier: Locale.preferredLanguages.first!)
    }()
}

extension Calendar {
    public static let preferred: Calendar = {
        var calendar = Calendar.current
        calendar.locale = .preferred
        return calendar
    }()
}
