//
//  SwiftUI+Extension.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import SwiftUI

extension Image {
    init?(data: Data) {
        guard let image = UIImage(data: data) else { return nil }
        self = .init(uiImage: image)
    }
}
