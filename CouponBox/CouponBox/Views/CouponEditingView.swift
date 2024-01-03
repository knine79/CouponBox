//
//  CouponEditingView.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/6/23.
//

import SwiftUI
import CouponBox_BusinessRules
import Combine

public struct CouponEditingView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: CouponEditingViewModel
    private let controller: CouponEditingViewController?
    @State private var alertPresented = false
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: CouponEditingViewModel, controller: CouponEditingViewController? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.controller = controller
        
        Publishers.MergeMany(
            viewModel.$barcode.removeDuplicates().map { _ in }.eraseToAnyPublisher(),
            viewModel.$expiresAt.removeDuplicates().map { _ in }.eraseToAnyPublisher(),
            viewModel.$name.removeDuplicates().map { _ in }.eraseToAnyPublisher(),
            viewModel.$shop.removeDuplicates().map { _ in }.eraseToAnyPublisher()
        )
        .receive(on: RunLoop.main)
        .sink { [self, viewModel] _ in
            self.controller?.couponDataDidChange(viewModel)
        }
        .store(in: &cancellables)
    }
    
    public var body: some View {
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
                        controller?.cancelButtonDidTap()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료".locaized) {
                        presentationMode.wrappedValue.dismiss()
                        controller?.doneButtonDidTap()
                    }
                    .disabled(!viewModel.canDone)
                }
            }
            .background(Color.background)
        }
        .onAppear(perform: {
            controller?.viewDidAppear()
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
        .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(Color.accent.gradient))
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
                .environment(\.locale, .preferred)
                .onChange(of: viewModel.expiresAt, { oldValue, newValue in
                    if viewModel.expiresAt != newValue.endOfDay {
                        viewModel.expiresAt = newValue.endOfDay
                    }
                })
                HStack(spacing: 0) {
                    if viewModel.expiredOrDueToExpire && !viewModel.loading {
                        Text(viewModel.expirationDescription)
                            .foregroundStyle(Color.red)
                            .font(.caption)
                    }
                    Spacer()
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text("쿠폰코드".locaized)
                    .bold()
                    .frame(width: 60, alignment: .topLeading)
                VStack(alignment: .leading, spacing: 4) {
                    TextField("필수".locaized, text: $viewModel.barcode)
                        .textFieldStyle(.roundedBorder)
                    if viewModel.alreadyExistWarningDisplayed {
                        Text("같은 쿠폰이 이미 추가되어 있습니다.".locaized)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = CouponEditingViewModel()
    viewModel.alreadyExistWarningDisplayed = true
    viewModel.canDone = false
    return CouponEditingView(viewModel: viewModel)
}

#Preview {
    let viewModel = CouponEditingViewModel()
    viewModel.loading = true
    return CouponEditingView(viewModel: viewModel)
}
