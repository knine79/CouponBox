//
//  Array+Extension.swift
//  CouponBox-BusinessRules
//
//  Created by Samuel Kim on 10/20/23.
//

import Foundation

public extension Array {
    func duplicateRemoved<Key: Hashable>(hasKeyProvider: (Element) -> Key, fromRight: Bool = false) -> Array {
        var existingMap = [Key: Void]()
        
        let match: (Element) -> Bool = { element in
            let key = hasKeyProvider(element)
            guard existingMap[key] == nil else {
                return false
            }
            existingMap[key] = ()
            return true
        }
        if fromRight {
            return self.reversed().filter(match).reversed()
        } else {
            return self.filter(match)
        }
    }
}
