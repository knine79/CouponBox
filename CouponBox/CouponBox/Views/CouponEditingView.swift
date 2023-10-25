//
//  CouponEditingView.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import SwiftUI
import CouponBox_BusinessRules

struct CouponEditingView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: CouponEditingViewModel
    private let controller: CouponEditingControllable
    @State private var alertPresented = false
    
    init(presenter: CouponEditingPresentable, controller: CouponEditingControllable) {
        self._viewModel = StateObject(wrappedValue: presenter.viewModel)
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
            .toolbarBackground(Color.background, for: .automatic)
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
            if let data = viewModel.imageData, let image = data.cgImage {
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
            SelectableTextField(title: "상품명".locaized, value: $viewModel.name, candidates: viewModel.recognizedTexts, placeholder: "필수".locaized, selectionDescription: "아래에서 상품명을 선택하세요.".locaized)
            SelectableTextField(title: "교환처".locaized, value: $viewModel.shop, candidates: viewModel.recognizedTexts, placeholder: "선택".locaized, selectionDescription: "아래에서 교환처를 선택하세요.".locaized)
            HStack {
                DatePicker(selection: $viewModel.expiresAt, displayedComponents: .date) {
                    HStack {
                        Text("유효기간".locaized)
                            .bold()
                            .frame(width: 60, alignment: .leading)
                    }
                }
                .onChange(of: viewModel.expiresAt, { oldValue, newValue in
                    if viewModel.expiresAt != newValue.endOfDay {
                        viewModel.expiresAt = newValue.endOfDay
                    }
                })
                .environment(\.locale, .preferred)
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
}

struct SelectableTextField: View {
    @State private var confirmationPresented = false

    let title: String
    let value: Binding<String>
    let candidates: [String]
    let placeholder: String
    let selectionDescription: String
    init(title: String, value: Binding<String>, candidates: [String], placeholder: String, selectionDescription: String) {
        self.title = title
        self.value = value
        self.candidates = candidates
        self.placeholder = placeholder
        self.selectionDescription = selectionDescription
    }
    
    var body: some View {
        HStack() {
            Text(title)
                .bold()
                .frame(width: 60, alignment: .leading)
            TextField(placeholder, text: value)
                .textFieldStyle(.roundedBorder)
                .confirmationDialog(selectionDescription, isPresented: $confirmationPresented, titleVisibility: .visible) {
                    ForEach(candidates, id: \.hashValue) { candidate in
                        Button(candidate) {
                            value.wrappedValue = candidate
                        }
                    }
                }
            Button("선택".locaized) {
                confirmationPresented.toggle()
            }
            .disabled(candidates.isEmpty)
        }
    }
}

#Preview {
    return Stubs.viewFactory.createCouponEditingView(couponImageData: UIImage(named: "sample")?.pngData() ?? Data())
}

#Preview {
    let useCase = Stubs.useCaseFactory.createCouponEditingUseCase(couponImageData: UIImage(named: "sample")?.pngData() ?? Data())
    useCase.viewModel.loading = true
    return CouponEditingView(presenter: useCase, controller: useCase)
}
