//
//  CouponDetail.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import SwiftUI
import CouponBox_BusinessRules

struct CouponDetailView: View {
    @Environment(\.scenePhase) private var phase
    @EnvironmentObject private var viewFactory: ViewFactory
    @State private var editViewPresented = false
    
    private let coupon: Coupon
    private let screenBrightnessController: ScreenBrightnessControllable
    init(coupon: Coupon, screenBrightnessController: ScreenBrightnessControllable) {
        self.coupon = coupon
        self.screenBrightnessController = screenBrightnessController
    }
    
    var body: some View {
        couponImageView
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .onAppear { screenBrightnessController.maximizeBrightness() }
            .onDisappear { screenBrightnessController.rollbackBrightness() }
            .onChange(of: editViewPresented) { oldValue, newValue in
                if newValue {
                    screenBrightnessController.rollbackBrightness()
                } else {
                    screenBrightnessController.maximizeBrightness()
                }
            }
            .onChange(of: phase) { oldValue, newValue in
                switch newValue {
                case .inactive:
                    screenBrightnessController.rollbackBrightness()
                case .active:
                    screenBrightnessController.maximizeBrightness()
                default: break
                }
            }
    }
    
    var couponImage: Image? {
        guard let image = coupon.imageData.cgImage else { return nil }
        return Image(image, scale: 1, label: Text("image"))
    }
    
    var couponImageView: some View {
        VStack {
            Group {
                if let image = couponImage {
                    image
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
            .toolbarBackground(Color.background, for: .automatic)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editViewPresented.toggle()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
                if let couponImage {
                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink(item: couponImage, preview: SharePreview(coupon.name, image: couponImage))
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
        Stubs.viewFactory.createCouponDetailView(coupon: Coupon(name: "아이스 아메리카노", shop: "", expiresAt: .endOfToday, code: "", imageData: UIImage(named: "sample")?.pngData() ?? Data()))
    }
}
