//
//  ImageAnalyzable.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/13/23.
//

import Foundation

public protocol ImageAnalyzable {
    func recognizeText(from imageData: Data, handle: @escaping ([String]) -> Void)
    func recognizeBarcode(from imageData: Data, handle: @escaping ([String]) -> Void)
}
