//
//  String+Extension.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/10/23.
//

import Foundation

extension String {
    public var locaized: String {
        NSLocalizedString(self, comment: "")
    }
}

extension String {
    var detectedDates: [Date] {
        let types: NSTextCheckingResult.CheckingType = [.date]
        let detector = try? NSDataDetector(types: types.rawValue)
        return detector?.matches(in: self, range: NSRange(location: 0, length: self.utf16.count)).map(\.date) as? [Date] ?? []
    }
}
