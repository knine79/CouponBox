//
//  CouponDetail.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import SwiftUI

struct CouponDetailView: View {
    @EnvironmentObject private var viewFactory: ViewFactory
    @State private var editViewPresented = false
    
    private let coupon: CouponRepositoryItem
    init(coupon: CouponRepositoryItem) {
        self.coupon = coupon
    }
    
    var body: some View {
        couponImage
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
    }
    
    var couponImage: some View {
        VStack {
            Group {
                if let image = coupon.imageData.cgImage {
                    Image(image, scale: 1, label: Text("image"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "app.gift")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.gray)
                        .aspectRatio(contentMode: .fit)
                        .padding(100)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(.accent.gradient))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("편집".locaized) {
                        editViewPresented.toggle()
                    }
                }
            }
            .sheet(isPresented: $editViewPresented) {
                viewFactory.createCouponEditingView(couponCode: coupon.code)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CouponDetailView(coupon: CouponRepositoryItem(name: "", expiresAt: Date(), code: "", imageData: UIImage(named: "sample")?.pngData() ?? Data()))
    }
}
