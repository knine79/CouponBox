//
//  Cache.swift
//  CouponBox
//
//  Created by Samuel Kim on 11/2/23.
//

import Foundation

private enum CacheKey: String {
    case expirationNotificationTime
}

@propertyWrapper private struct UserDefault<T> {
    private let key: CacheKey
    private let defaultValue: T
    
    var wrappedValue: T {
        get { (UserDefaults.standard.object(forKey: self.key.rawValue) as? T) ?? self.defaultValue }
        set { UserDefaults.standard.setValue(newValue, forKey: key.rawValue) }
    }
    
    fileprivate init(key: CacheKey, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
}

public final class Cache {
    public init() {}
    
    @UserDefault<TimeInterval>(key: CacheKey.expirationNotificationTime, defaultValue: 7 * 3600) var expirationNotificationTime
}

