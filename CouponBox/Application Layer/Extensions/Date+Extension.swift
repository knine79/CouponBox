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
        formatter.dateTimeStyle = .named
        formatter.locale = Locale.preferred
        
        return formatter.localizedString(for: self.addingTimeInterval(24*3600), relativeTo: Date())
    }
    
    static var today: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        return calendar.date(from: components)!
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
