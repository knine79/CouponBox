//
//  CouponListView.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import SwiftUI
import PhotosUI

struct CouponListView: View {
    @EnvironmentObject private var viewFactory: ViewFactory
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var registrationSheetPresented: Bool = false
    @ObservedObject private var viewModel: CouponListViewModel
    
    @State private var selectedImageData: Data?
    
    private let presenter: CouponListPresentable
    private let controller: CouponListControllable
    init(presenter: CouponListPresentable, controller: CouponListControllable) {
        self.presenter = presenter
        self.viewModel = presenter.viewModel
        self.controller = controller
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationStack {
                Group {
                    if viewModel.coupons.isEmpty {
                        emptyCouponsView
                    } else {
                        couponListView
                    }
                }
                .background(Color.background)
                .navigationTitle("내 쿠폰".locaized)
                .toolbarBackground(Color.background, for: .automatic)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarTrailing) {
                        PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .not(.livePhotos)])) {
                            Image(systemName: "plus")
                        }
                    }
                })
                .navigationDestination(for: CouponVO.self) { coupon in
                    viewFactory.createCouponDetailView(coupon: coupon)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .onChange(of: selectedItem) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            selectedItem = nil
                        }
                    }
                }
                .sheet(isPresented: Binding(get: {
                    selectedImageData != nil
                }, set: {
                    selectedImageData = $0 ? selectedImageData : nil
                })) {
                    if let selectedImageData = selectedImageData {
                        viewFactory.createCouponEditingView(couponImageData: selectedImageData)
                    }
                }
            }
        }
        .onAppear {
            controller.fetchCouponList()
        }
    }
    
    var emptyCouponsView: some View {
        Group {
            if viewModel.loading {
                ProgressView("쿠폰을 로딩하고 있어요.".locaized)
            } else {
                VStack {
                    PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .not(.livePhotos)])) {
                        VStack {
                            Text("저장된 쿠폰이 없어요.".locaized)
                                .foregroundStyle(Color.gray)
                            Image(systemName: "photo.badge.plus")
                                .resizable()
                                .renderingMode(.original)
                                .foregroundStyle(Color.gray)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50)
                                .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var couponListView: some View {
        List {
            ForEach($viewModel.coupons, id: \.code, editActions: .delete) { $coupon in
                NavigationLink(value: coupon) {
                    HStack {
                        Group {
                            if let image = Image(data: coupon.imageData) {
                                image
                                    .resizable()
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .resizable()
                                    .renderingMode(.original)
                                    .foregroundStyle(Color.gray)
                                    .padding()
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(.accent.gradient))
                        
                        VStack(alignment: .leading) {
                            Text(coupon.name)
                            HStack {
                                Text("유효기간".locaized)
                                Text(coupon.expiresAt, style: .date)
                                    .environment(\.locale, .preferred)
                                Text("(\(coupon.expiresAt.relativeTime))")
                                    .environment(\.locale, .preferred)
                            }
                            .foregroundStyle(coupon.expiresAt.expiredOrExpiresIn(days: 7) ? Color.red : Color.gray)
                            .font(.caption)
                        }
                    }
                }
            }
            .onDelete(perform: { indexSet in
                indexSet.forEach {
                    controller.removeCoupon(code: viewModel.coupons[$0].code)
                }
            })
        }
        .listStyle(.plain)
    }
}

#Preview {
    let useCase = CouponListUseCase(repository: FakeCouponListRepository(coupons: [
        CouponRepositoryItem(name: "[스타벅스] 아이스 아메리카노", expiresAt: .today.addingTimeInterval(7*24*3600), code: "123323456122", imageData: UIImage(named: "sample")?.pngData() ?? Data()),
        CouponRepositoryItem(name: "[스타벅스] 아메리카노", expiresAt: .today, code: "900369921874", imageData: UIImage(named: "sample3")?.pngData() ?? Data())
    ]), store: DataStore())
    return CouponListView(presenter: useCase, controller: useCase)
        .environmentObject(Stubs.viewFactory)
}

#Preview {
    let useCase = CouponListUseCase(repository: FakeCouponListRepository(coupons: []), store: DataStore())
    return CouponListView(presenter: useCase, controller: useCase)
}

#Preview {
    let useCase = CouponListUseCase(repository: FakeCouponListRepository(coupons: []), store: DataStore())
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
        useCase.viewModel.loading = true
    }
    return CouponListView(presenter: useCase, controller: useCase)
}
