//
//  CouponEditingViewModel.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import Foundation

public final class CouponEditingViewModel: ObservableObject {
    @Published var imageData: Data?
    @Published var name: String = ""
    @Published var expiresAt: Date = .init()
    @Published var barcode: String = ""
    
    @Published var nameCandidates: [String] = []
    @Published var loading: Bool = false
    @Published var canDone: Bool = false
    
    var toRepositoryItem: CouponRepositoryItem {
        CouponRepositoryItem(name: name, expiresAt: expiresAt, code: barcode, imageData: imageData ?? Data())
    }
}
