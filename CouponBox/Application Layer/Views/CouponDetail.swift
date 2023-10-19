//
//  CouponDetail.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import SwiftUI

struct CouponDetailView: View {
    @Environment(\.scenePhase) private var phase
    @EnvironmentObject private var viewFactory: ViewFactory
    @State private var editViewPresented = false
    
    private let coupon: CouponVO
    private let screenBrightnessController: ScreenBrightnessControllable
    init(coupon: CouponVO, screenBrightnessController: ScreenBrightnessControllable) {
        self.coupon = coupon
        self.screenBrightnessController = screenBrightnessController
    }
    
    var body: some View {
        couponImage
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
            .toolbarBackground(Color.background, for: .automatic)
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
        let useCase = ScreenBrightnessUseCase(store: DataStore(), screenController: ScreenController())
        CouponDetailView(coupon: CouponVO(name: "", expiresAt: Date(), code: "", imageData: UIImage(named: "sample")?.pngData() ?? Data()), screenBrightnessController: useCase)
    }
}
