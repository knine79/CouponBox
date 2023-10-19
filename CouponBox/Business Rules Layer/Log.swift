//
//  Log.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/16/23.
//

import Foundation

public func printLog(_ items: Any, file: String = #file, line: Int = #line) {
    #if DEBUG
    let filename = String(file.split(separator: "/").last ?? "")
    NSLog("\(filename):\(line) 👉 \(items)")
    #endif
}
