//
//  Date+Extension.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import Foundation

extension Date {
    public var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.locale = Locale.preferred
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    public init?(dateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        self = date
    }
    
    public var startOfDay: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return calendar.date(from: components)!
    }
    
    public func timeOfDay(timeComponents: DateComponents) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = timeComponents.second
        return calendar.date(from: components)!
    }
    
    public var endOfDay: Date {
        timeOfDay(timeComponents: DateComponents(hour: 23, minute: 59, second: 59))
    }
    
    public static var startOfToday: Date {
        Date().startOfDay
    }
    
    public static var endOfToday: Date {
        Date().endOfDay
    }
    
    public func expiresIn(days: Int) -> Bool {
        !expired && Date.endOfToday.distance(to: self.addingTimeInterval(1)) < TimeInterval(3600 * 24 * days)
    }
    
    public var expired: Bool {
        Date.endOfToday.distance(to: self.addingTimeInterval(1)) <= 0
    }
    
    public func expiredOrExpiresIn(days: Int) -> Bool {
        expired || expiresIn(days: days)
    }
}
