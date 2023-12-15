//
//  CouponListView.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import SwiftUI
import PhotosUI
import CouponBox_BusinessRules

struct CouponListView: View {
    @EnvironmentObject private var viewFactory: ViewFactory
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var detentsPresented: Bool = false
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
                    if viewModel.isEmpty {
                        emptyCouponsView
                    } else {
                        couponListView
                    }
                }
                .background(Color.background)
                .navigationTitle("내 쿠폰".locaized)
                .toolbarBackground(Color.background, for: .automatic)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        PhotosPicker(selection: $selectedItem, matching: .any(of: [.images, .not(.livePhotos)])) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            detentsPresented.toggle()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                })
                .navigationDestination(for: Coupon.self) { coupon in
                    viewFactory.createCouponDetailView(coupon: coupon)
                        .navigationBarTitleDisplayMode(.inline)
                        .onDisappear {
                            controller.fetchCouponList()
                        }
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
                .sheet(isPresented: $detentsPresented, content: {
                    settingView
                        .onAppear {
                            controller.loadExpirationNotificationTime()
                        }
                        .presentationDetents([.height(340)])
                })
                
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
            couponListSection(title: nil, coupons: $viewModel.notSoonToExpireCoupons)
            couponListSection(title: "곧 만료".locaized, coupons: $viewModel.soonToExpireCoupons)
            couponListSection(title: "만료됨", coupons: $viewModel.expiredCoupons)
        }
        .listStyle(.plain)
    }
    
    func couponListSection(title: String?, coupons: Binding<[Coupon]>) -> some View {
        Group {
            if !coupons.isEmpty {
                if let title {
                    Section(title) {
                        couponListSectionContent(coupons: coupons)
                    }
                } else {
                    Section {
                        couponListSectionContent(coupons: coupons)
                    }
                }
            }
        }
    }
    
    func couponListSectionContent(coupons: Binding<[Coupon]>) -> some View {
        ForEach(coupons, id: \.code, editActions: .delete) { $coupon in
            NavigationLink(value: coupon) {
                couponListItemView(coupon: coupon)
            }
            .disabled(coupon.expiresAt.expired)
        }
        .onDelete(perform: { indexSet in
            indexSet.forEach {
                controller.removeCoupon(code: coupons.wrappedValue[$0].code)
            }
        })
    }
    
    func couponListItemView(coupon: Coupon) -> some View {
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
                Text(coupon.shop)
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                Text(coupon.name)
                HStack(spacing: 0) {
                    Text(coupon.expiresAt, style: .date)
                        .environment(\.locale, .preferred)
                    Text(coupon.expiresAt.expired ? "(만료됨)".locaized : "(\(coupon.expiresAt.relativeTime) \("만료".locaized))")
                        .environment(\.locale, .preferred)
                }
                .foregroundStyle(coupon.expiresAt.expiredOrExpiresIn(days: 7) ? Color.red : Color.gray)
                .font(.caption)
            }
        }
    }
    
    var settingView: some View {
        VStack {
            HStack {
                Button("취소".locaized) {
                    detentsPresented.toggle()
                }
                Spacer()
                Button {
                    controller.saveExpirationNotificationTime()
                    detentsPresented.toggle()
                } label: {
                    Text("저장".locaized)
                }
            }
            .padding(.bottom)
            Spacer()
            Text("하루 중 쿠폰 만료 알림을 언제 받고 싶으세요?".locaized)
            Text("쿠폰이 만료되기 7일전, 3일전, 당일에 알림을 보내드립니다.".locaized)
                .font(.caption)
                .foregroundStyle(Color.gray)
            DatePicker("", selection: $viewModel.notificationTime, displayedComponents: .hourAndMinute)
                .environment(\.locale, .preferred)
                .datePickerStyle(.wheel)
                .labelsHidden()
            
            
        }
        .padding(24)
    }
}

#Preview {
    let spyRepository = SpyRepositoryContainer()
    spyRepository.couponList = FakeCouponListRepository(coupons: [
        Coupon(name: "아이스 아메리카노1", shop: "스타벅스", expiresAt: .endOfToday.addingTimeInterval(14*24*3600), code: "1233234561221", imageData: UIImage(named: "sample")?.pngData() ?? Data()),
        Coupon(name: "아이스 아메리카노2", shop: "스타벅스", expiresAt: .endOfToday.addingTimeInterval(-24*3600), code: "1233234561222", imageData: UIImage(named: "sample")?.pngData() ?? Data()),
        Coupon(name: "아이스 아메리카노3", shop: "스타벅스", expiresAt: .endOfToday.addingTimeInterval(7*24*3600), code: "1233234561223", imageData: UIImage(named: "sample")?.pngData() ?? Data()),
        Coupon(name: "아이스 아메리카노4", shop: "스타벅스", expiresAt: .endOfToday, code: "900369921874", imageData: UIImage(named: "sample3")?.pngData() ?? Data())
    ])
    spyRepository.settings = FakeAppSettingsRepository()
    let useCase = Stubs.useCaseFactory(spyRepository: spyRepository).createCouponListUseCase()
    return CouponListView(presenter: useCase, controller: useCase)
        .environmentObject(Stubs.viewFactory)
}

#Preview {
    Stubs.viewFactory.createCouponListView()
}

#Preview {
    let useCase = Stubs.useCaseFactory.createCouponListUseCase()
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
        useCase.viewModel.loading = true
    }
    return CouponListView(presenter: useCase, controller: useCase)
}
