//
//  CouponEditingUseCase.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import Foundation
import Combine

public protocol CouponEditingPresentable {
    var viewModel: CouponEditingViewModel { get }
}

public protocol CouponEditingControllable {
    func viewDidAppear()
    func cancelButtonDidTap()
    func doneButtonDidTap()
}

public final class CouponEditingUseCase: CouponEditingPresentable, CouponEditingControllable {
    enum EditingMode {
        case add, update
    }
    
    private let couponImageData: Data?
    private let couponCode: String?
    private let completionHandler: (_ isDone: Bool) -> Void
    private let repository: RepositoryContainerProtocol
    private let store: DataStorable
    private let imageAnalyzer: ImageAnalyzable
    
    private let mode: EditingMode
    private var dirty = CurrentValueSubject<Bool, Never>(false)
    
    public var viewModel = CouponEditingViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init(couponImageData: Data, completionHandler: @escaping (_ isDone: Bool) -> Void = { _ in }, repository: RepositoryContainerProtocol, store: DataStorable, imageAnalyzer: ImageAnalyzable) {
        self.couponImageData = couponImageData
        self.completionHandler = completionHandler
        self.couponCode = nil
        self.mode = .add
        
        self.repository = repository
        self.store = store
        self.imageAnalyzer = imageAnalyzer
        
        setupTriggers()
    }
    
    init(couponCode: String, repository: RepositoryContainerProtocol, store: DataStorable, imageAnalyzer: ImageAnalyzable) {
        self.couponImageData = nil
        self.completionHandler = { _ in }
        self.couponCode = couponCode
        self.mode = .update
        
        self.repository = repository
        self.store = store
        self.imageAnalyzer = imageAnalyzer
        
        setupTriggers()
    }
    
    private func setupTriggers() {
        Publishers.CombineLatest(
            Publishers.CombineLatest3(viewModel.$barcode.removeDuplicates(),
                                      viewModel.$name.removeDuplicates(),
                                      viewModel.$shop.removeDuplicates()),
            Publishers.CombineLatest(viewModel.$expiresAt,
                                     viewModel.$imageData.removeDuplicates())
        )
        .sink { [weak self] _, _ in
            self?.dirty.send(true)
        }.store(in: &cancellables)
        
        dirty.debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                viewModel.canDone = canDone == true
                viewModel.alreadyExistWarningDisplayed = mode == .add && isExistCoupon(code: viewModel.barcode)
            }.store(in: &cancellables)
    }
    
    public func viewDidAppear() {
        if let couponImageData {
            couponImageDidInput(imageData: couponImageData)
        } else if let couponCode {
            let item = try? repository.couponList.fetchCoupon(code: couponCode)
            viewModel.imageData = item?.imageData ?? Data()
            viewModel.barcode = item?.code ?? ""
            viewModel.name = item?.name ?? ""
            viewModel.shop = item?.shop ?? ""
            viewModel.expiresAt = item?.expiresAt ?? .endOfToday
            if let imageData = item?.imageData {
                viewModel.loading = true
                imageAnalyzer.recognizeText(from: imageData) { [weak self] texts in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        viewModel.recognizedTexts = []
                        texts.forEach { [weak self] in
                            if $0.detectedDates.isEmpty {
                                self?.viewModel.recognizedTexts.append($0)
                            }
                        }
                        viewModel.recognizedTexts = viewModel.recognizedTexts.duplicateRemoved(hasKeyProvider: { $0.hashValue })
                        viewModel.loading = false
                    }
                }
            }
        }
        dirty.send(false)
    }
    
    public func cancelButtonDidTap() {
        completionHandler(false)
    }
    
    public func doneButtonDidTap() {
        saveCoupon()
        completionHandler(true)
    }
    
    private func saveCoupon() {
        let item = viewModel.toVO
        if (try? repository.couponList.isExistCoupon(code: item.code)) == true {
            try? repository.couponList.updateCoupon(item)
            store.patch(key: .couponList) {
                var value: [Coupon] = $0 ?? []
                value.removeAll(where: { $0.code == item.code })
                value.append(item)
                return value
            }
        } else {
            try? repository.couponList.addCoupon(item)
            store.patch(key: .couponList) {
                var value: [Coupon] = $0 ?? []
                value.append(item)
                return value
            }
        }
    }
    
    private func couponImageDidInput(imageData: Data) {
        viewModel.imageData = imageData
        viewModel.loading = true
        let dispatchGroup = DispatchGroup()
        
        DispatchQueue.global(qos: .userInitiated).async {
            dispatchGroup.enter()
            self.imageAnalyzer.recognizeBarcode(from: imageData) { [weak self] barcode in
                DispatchQueue.main.sync {
                    self?.viewModel.barcode = barcode.first ?? ""
                    dispatchGroup.leave()
                }
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            dispatchGroup.enter()
            self.imageAnalyzer.recognizeText(from: imageData) { [weak self] texts in
                DispatchQueue.main.sync { [weak self] in
                    guard let self else { return }
                    viewModel.recognizedTexts = []
                    var allDetectedDates: [Date] = []
                    texts.forEach { [weak self] in
                        let detectedDates = $0.detectedDates
                        if detectedDates.isEmpty {
                            self?.viewModel.recognizedTexts.append($0)
                        } else {
                            allDetectedDates.append(contentsOf: detectedDates.map(\.endOfDay))
                        }
                    }
                    viewModel.expiresAt = allDetectedDates.sorted().last ?? Date()
                    viewModel.recognizedTexts = viewModel.recognizedTexts.duplicateRemoved(hasKeyProvider: { $0.hashValue })
                    viewModel.name = viewModel.recognizedTexts.dropFirst().first ?? ""
                    viewModel.shop = viewModel.recognizedTexts.first ?? ""
                    dispatchGroup.leave()
                }
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            dispatchGroup.wait()
            DispatchQueue.main.sync {
                self.viewModel.loading = false
            }
        }
    }
    
    private var canDone: Bool {
        !viewModel.barcode.isEmpty
        && !viewModel.name.isEmpty
        && !viewModel.expiresAt.expired
        && viewModel.imageData != nil
        && ((mode == .add && !isExistCoupon(code: viewModel.barcode)) || mode == .update && dirty.value)
    }
    
    private func isExistCoupon(code: String) -> Bool {
        (try? repository.couponList.isExistCoupon(code: code)) == true
    }
}
