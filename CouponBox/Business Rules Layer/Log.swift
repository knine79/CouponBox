//
//  Log.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/16/23.
//

import Foundation

public func printLog(_ items: Any, file: String = #file, line: Int = #line) {
    #if DEBUG
    let formatter = DateFormatter()
    formatter.locale = NSLocale.current
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let filename = String(file.split(separator: "/").last ?? "")
    NSLog("\(formatter.string(from: Date())) \(filename):\(line) 👉 \(items)")
    #endif
}
