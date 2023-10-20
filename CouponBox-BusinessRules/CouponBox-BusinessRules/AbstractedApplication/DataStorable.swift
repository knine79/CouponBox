//
//  DataStore.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import Foundation
import Combine

public enum StoreKey: String {
    case couponList
    case legacyScreenBrightness
}

public protocol DataStorable: AnyObject {
    func value<T>(key: StoreKey, typeOf: T.Type) -> T?
    func value<T>(key: StoreKey, defaultValue: T) -> T
    func valuePublisher<T>(key: StoreKey, typeOf: T.Type) -> AnyPublisher<T?, Never>
    func update(key: StoreKey, value: Any?)
    func patch<T>(key: StoreKey, patch: @escaping (T?) -> T?)
}

public final class DataStore: DataStorable {
    private let serialQueue: DispatchQueue
    private let storeMap = CurrentValueSubject<[StoreKey: Any], Never>([:])
    
    public init(serialQueue: DispatchQueue = DispatchQueue(label: "queue.datastore", qos: .userInteractive)) {
        self.serialQueue = serialQueue
    }
    
    public func value<T>(key: StoreKey, typeOf: T.Type) -> T? {
        storeMap.value[key] as? T
    }
    
    public func value<T>(key: StoreKey, defaultValue: T) -> T {
        (storeMap.value[key] as? T) ?? defaultValue
    }
    
    public func valuePublisher<T>(key: StoreKey, typeOf: T.Type) -> AnyPublisher<T?, Never> {
        storeMap.map { $0[key] as? T }.eraseToAnyPublisher()
    }
    
    public func update(key: StoreKey, value: Any?) {
        serialQueue.sync {[weak self] in
            guard let self = self else { return }
            var map = self.storeMap.value
            if let value = value {
                map.updateValue(value, forKey: key)
            } else {
                map.removeValue(forKey: key)
            }
            self.storeMap.send(map)
        }
    }
    
    public func patch<T>(key: StoreKey, patch: @escaping (T?) -> T?) {
        serialQueue.sync { [weak self] in
            guard let self = self else { return }
            var map = self.storeMap.value
            let oldValue = map[key] as? T
            
            guard let newValue = patch(oldValue) else { return }
            map[key] = newValue
            self.storeMap.send(map)
        }
    }
}
