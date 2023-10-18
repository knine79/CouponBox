//
//  CouponEditingView.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import SwiftUI

struct CouponEditingView: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject private var viewModel: CouponEditingViewModel
    private let controller: CouponEditingControllable
    @State private var alertPresented = false
    @State private var confirmationPresented = false
    
    init(presenter: CouponEditingPresentable, controller: CouponEditingControllable) {
        self.viewModel = presenter.viewModel
        self.controller = controller
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                couponImage
                ZStack {
                    recognizedInfos
                    if viewModel.loading {
                        ProgressView()
                    }
                }
            }
            .scrollIndicators(.hidden, axes: .vertical)
            .padding(.horizontal, 24)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소".locaized) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료".locaized) {
                        presentationMode.wrappedValue.dismiss()
                        controller.saveCoupon()
                    }
                    .disabled(!viewModel.canDone)
                }
            }
            .background(Color.background)
        }
        .onAppear(perform: {
            controller.viewDidAppear()
        })
    }
    
    var couponImage: some View {
        Group {
            if let data = viewModel.imageData, let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
               let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) {
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
    }
    
    var recognizedInfos: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Text("아래 정보가 맞는지 확인해주세요.")
                    .font(.system(size: 24))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            HStack() {
                Text("상품명".locaized)
                    .bold()
                    .frame(width: 60, alignment: .leading)
                TextField("필수".locaized, text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)
                    .confirmationDialog("아래에서 상품명을 선택하세요".locaized, isPresented: $confirmationPresented, titleVisibility: .visible) {
                        ForEach(viewModel.nameCandidates, id: \.hashValue) { candidate in
                            Button(candidate) {
                                viewModel.name = candidate
                            }
                        }
                    }
                Button("선택".locaized) {
                    confirmationPresented.toggle()
                }
                .disabled(viewModel.nameCandidates.isEmpty)
            }
            HStack {
                DatePicker(selection: $viewModel.expiresAt, displayedComponents: .date) {
                    HStack {
                        Text("유효기간".locaized)
                            .bold()
                            .frame(width: 60, alignment: .leading)
                    }
                }
                .environment(\.locale, locale)
                HStack(spacing: 0) {
                    Text("\(viewModel.expiresAt.relativeTime) 만료".locaized)
                    Spacer()
                }
                .foregroundStyle(viewModel.expiresAt.expiredOrExpiresIn(days: 7) ? Color.red : Color.primary)
            }
            HStack {
                Text("쿠폰코드".locaized)
                    .bold()
                    .frame(width: 60, alignment: .leading)
                TextField("필수".locaized, text: $viewModel.barcode)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    private let locale: Locale = {
        Locale(identifier: Locale.preferredLanguages.first!)
    }()
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: Locale.preferredLanguages.first!)
        return calendar
    }()
}

#Preview {
    let useCase = CouponEditingUseCase(couponImageData: UIImage(named: "sample")?.pngData() ?? Data(), repository: FakeCouponListRepository(), store: DataStore(), imageAnalyzer: ImageAnalyzer())
//    useCase.viewModel.loading = true
    return CouponEditingView(presenter: useCase, controller: useCase)
}
