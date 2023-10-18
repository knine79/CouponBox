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
    func saveCoupon()
}

public class CouponEditingUseCase: CouponEditingPresentable, CouponEditingControllable {
    enum EditingMode {
        case add, update
    }
    
    private let couponImageData: Data?
    private let couponCode: String?
    private let repository: CouponListRepositoryProtocol
    private let store: DataStorable
    private let imageAnalyzer: ImageAnalyzable
    
    private let mode: EditingMode
    private var dirty = CurrentValueSubject<Bool, Never>(false)
    
    public var viewModel = CouponEditingViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init(couponImageData: Data, repository: CouponListRepositoryProtocol, store: DataStorable, imageAnalyzer: ImageAnalyzable) {
        self.couponImageData = couponImageData
        self.couponCode = nil
        self.mode = .add
        
        self.repository = repository
        self.store = store
        self.imageAnalyzer = imageAnalyzer
        
        setupTriggers()
    }
    
    init(couponCode: String, repository: CouponListRepositoryProtocol, store: DataStorable, imageAnalyzer: ImageAnalyzable) {
        self.couponImageData = nil
        self.couponCode = couponCode
        self.mode = .update
        
        self.repository = repository
        self.store = store
        self.imageAnalyzer = imageAnalyzer
        
        setupTriggers()
    }
    
    private func setupTriggers() {
        Publishers.CombineLatest4(viewModel.$barcode.removeDuplicates(), viewModel.$name.removeDuplicates(), viewModel.$expiresAt, viewModel.$imageData.removeDuplicates())
            .print()
            .sink { [weak self] _, _, _, _ in
                self?.dirty.send(true)
            }.store(in: &cancellables)
        
        dirty.debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.viewModel.canDone = self?.canDone == true
            }.store(in: &cancellables)
    }
    
    public func viewDidAppear() {
        if let couponImageData {
            couponImageDidInput(imageData: couponImageData)
        } else if let couponCode {
            let item = try? repository.fetchCoupon(code: couponCode)
            viewModel.imageData = item?.imageData ?? Data()
            viewModel.barcode = item?.code ?? ""
            viewModel.name = item?.name ?? ""
            viewModel.expiresAt = item?.expiresAt ?? Date()
            if let imageData = item?.imageData {
                viewModel.loading = true
                imageAnalyzer.recognizeText(from: imageData) { [weak self] texts in
                    DispatchQueue.main.async {
                        self?.viewModel.nameCandidates = []
                        texts.forEach { [weak self] in
                            if (try? /(\d{4})[\.\/년]+ ?(\d{1,2})[\.\/월]+ ?(\d{1,2})[\.\/일]?/.firstMatch(in: $0)) == nil {
                                self?.viewModel.nameCandidates.append($0)
                            }
                        }
                        self?.viewModel.loading = false
                    }
                }
            }
        }
        dirty.send(false)
    }
    
    public func saveCoupon() {
        let item = viewModel.toRepositoryItem
        if (try? repository.isExistCoupon(code: item.code)) == true {
            try? repository.updateCoupon(item)
            store.patch(key: .couponList) {
                var value: [CouponRepositoryItem] = $0 ?? []
                value.removeAll(where: { $0.code == item.code })
                value.append(item)
                return value
            }
        } else {
            try? repository.addCoupon(item)
            store.patch(key: .couponList) {
                var value: [CouponRepositoryItem] = $0 ?? []
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
                DispatchQueue.main.sync {
                    self?.viewModel.nameCandidates = []
                    texts.forEach { [weak self] in
                        if let match = try? /(\d{4})[\.\/년]+ ?(\d{1,2})[\.\/월]+ ?(\d{1,2})[\.\/일]?/.firstMatch(in: $0)?.output {
                            self?.viewModel.expiresAt = DateComponents(calendar: .current, timeZone: .current, year: Int(match.1), month: Int(match.2), day: Int(match.3)).date ?? Date()
                        } else {
                            self?.viewModel.nameCandidates.append($0)
                        }
                    }
                    self?.viewModel.name = self?.viewModel.nameCandidates.first ?? ""
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
        && ((mode == .add && isExistCoupon(code: viewModel.barcode)) || mode == .update && dirty.value)
    }
    
    private func isExistCoupon(code: String) -> Bool {
        (try? repository.isExistCoupon(code: code)) == false
    }
}
