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
    
    private let viewModel: CouponViewModel
    private let controller: CouponDetailViewController?
    init(viewModel: CouponViewModel, controller: CouponDetailViewController? = nil) {
        self.viewModel = viewModel
        self.controller = controller
    }
    
    var body: some View {
        couponImageView
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .onAppear { controller?.maximizeBrightness() }
            .onDisappear { controller?.rollbackBrightness() }
            .onChange(of: editViewPresented) { oldValue, newValue in
                if newValue {
                    controller?.rollbackBrightness()
                } else {
                    controller?.maximizeBrightness()
                }
            }
            .onChange(of: phase) { oldValue, newValue in
                switch newValue {
                case .inactive:
                    controller?.rollbackBrightness()
                case .active:
                    controller?.maximizeBrightness()
                default: break
                }
            }
    }
    
    var couponImage: Image? {
        guard let image = viewModel.imageData.cgImage else { return nil }
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
                        ShareLink(item: couponImage, preview: SharePreview(viewModel.name, image: couponImage))
                    }
                }
            }
            .sheet(isPresented: $editViewPresented) {
                viewFactory.createCouponEditingView(couponCode: viewModel.code)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Stubs.viewFactory.createCouponDetailView(coupon: CouponViewModel(from: Coupon(name: "아이스 아메리카노", shop: "", expiresAt: .endOfToday, code: "", imageData: UIImage(named: "sample")?.pngData() ?? Data())))
    }
}
