//
//  Date+Extension.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import Foundation

extension Date {
    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.locale = Locale(identifier: Locale.preferredLanguages.first!)
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    func expiresIn(days: Int) -> Bool {
        Date().distance(to: self) < TimeInterval(3600 * 24 * days)
    }
    
    var expired: Bool {
        Date().distance(to: self) <= 0
    }
    
    func expiredOrExpiresIn(days: Int) -> Bool {
        expired || expiresIn(days: days)
    }
}
