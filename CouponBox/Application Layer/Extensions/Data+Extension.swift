//
//  Data+Extension.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import CoreImage

extension Data {
    var cgImage: CGImage? {
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil),
              let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            return nil
        }
        return image
    }
}
