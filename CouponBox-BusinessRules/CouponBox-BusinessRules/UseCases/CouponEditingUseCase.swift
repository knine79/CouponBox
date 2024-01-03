//
//  CouponEditingUseCase.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/12/23.
//

import Foundation
import Combine

public protocol CouponEditingUseCaseOutputProtocol {
    func presentCouponData(_ data: Coupon)
    func presentRecognizedTexts(_ texts: [String])
    func presentDoneButton(canDone: Bool)
    func presentProgress(isLoading: Bool)
    func presentAlreadyExistWarning(_ show: Bool)
    func presentCouponValidation(_ coupon: Coupon)
}

public protocol CouponEditingUseCaseInputProtocol {
    func loadView()
    func edit(_ data: Coupon)
    func cancel()
    func save()
}

public final class CouponEditingUseCase: CouponEditingUseCaseInputProtocol {
    enum EditingMode {
        case add, update
    }
    
    private let couponImageData: Data?
    private let couponCode: String?
    private let completionHandler: (_ isDone: Bool) -> Void
    private let presenter: CouponEditingUseCaseOutputProtocol?
    private let repository: RepositoryContainerProtocol
    private let store: DataStorable
    private let imageAnalyzer: ImageAnalyzable
    
    private var couponData: Coupon?
    private let mode: EditingMode
    private var dirty = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables = Set<AnyCancellable>()
    
    init(presenter: CouponEditingUseCaseOutputProtocol?,
         repository: RepositoryContainerProtocol,
         store: DataStorable,
         imageAnalyzer: ImageAnalyzable,
         couponImageData: Data,
         completionHandler: @escaping (_ isDone: Bool) -> Void = { _ in }) 
    {
        self.couponImageData = couponImageData
        self.completionHandler = completionHandler
        self.couponCode = nil
        self.mode = .add
        
        self.presenter = presenter
        self.repository = repository
        self.store = store
        self.imageAnalyzer = imageAnalyzer
        
        setupTriggers()
    }
    
    init(presenter: CouponEditingUseCaseOutputProtocol?, 
         repository: RepositoryContainerProtocol,
         store: DataStorable,
         imageAnalyzer: ImageAnalyzable,
         couponCode: String) 
    {
        self.couponImageData = nil
        self.completionHandler = { _ in }
        self.couponCode = couponCode
        self.mode = .update
        
        self.presenter = presenter
        self.repository = repository
        self.store = store
        self.imageAnalyzer = imageAnalyzer
        
        setupTriggers()
    }
    
    private func setupTriggers() {
        dirty.filter { $0 }
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self, let couponData = couponData else { return }
                presenter?.presentDoneButton(canDone: canDone)
                presenter?.presentCouponValidation(couponData)
                presenter?.presentAlreadyExistWarning(mode == .add && isExistCoupon(code: couponData.code))
            }
            .store(in: &cancellables)
    }
    
    public func loadView() {
        if let couponImageData {
            loadViewFromImage(couponImageData)
        } else if let couponCode {
            loadViewFromCouponCode(couponCode)
        }
    }
    
    public func edit(_ data: Coupon) {
        dirty.send(true)
        couponData = data
    }
    
    public func cancel() {
        completionHandler(false)
        dirty.send(false)
        couponData = nil
    }
    
    public func save() {
        saveCoupon()
        completionHandler(true)
        dirty.send(false)
        couponData = nil
    }
    
    private func saveCoupon() {
        guard let couponData else { return }
        if (try? repository.couponList.isExistCoupon(code: couponData.code)) == true {
            try? repository.couponList.updateCoupon(couponData)
            store.patch(key: .couponList) {
                var value: [Coupon] = $0 ?? []
                value.removeAll(where: { $0.code == couponData.code })
                value.append(couponData)
                return value
            }
        } else {
            try? repository.couponList.addCoupon(couponData)
            store.patch(key: .couponList) {
                var value: [Coupon] = $0 ?? []
                value.append(couponData)
                return value
            }
        }
    }
    
    private func loadViewFromImage(_ imageData: Data) {
        
        var code = ""
        var expiresAt = Date()
        var name = ""
        var shop = ""
        
        presenter?.presentProgress(isLoading: true)
        let dispatchGroup = DispatchGroup()
        
        DispatchQueue.global(qos: .userInitiated).async {
            dispatchGroup.enter()
            self.imageAnalyzer.recognizeBarcode(from: imageData) { barcode in
                DispatchQueue.main.sync {
                    code = barcode.first ?? ""
                    dispatchGroup.leave()
                }
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            dispatchGroup.enter()
            self.imageAnalyzer.recognizeText(from: imageData) { [weak self] texts in
                DispatchQueue.main.sync { [weak self] in
                    guard let self else { return }
                    var recognizedTexts = [String]()
                    var allDetectedDates: [Date] = []
                    texts.forEach {
                        let detectedDates = $0.detectedDates
                        if detectedDates.isEmpty {
                            recognizedTexts.append($0)
                        } else {
                            allDetectedDates.append(contentsOf: detectedDates.map(\.endOfDay))
                        }
                    }
                    recognizedTexts = recognizedTexts.duplicateRemoved(hasKeyProvider: { $0.hashValue })
                    presenter?.presentRecognizedTexts(recognizedTexts)
                    expiresAt = allDetectedDates.sorted().last ?? Date()
                    name = recognizedTexts.dropFirst().first ?? ""
                    shop = recognizedTexts.first ?? ""
                    dispatchGroup.leave()
                }
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            dispatchGroup.wait()
            DispatchQueue.main.sync {
                self.couponData = Coupon(name: name, shop: shop, expiresAt: expiresAt, code: code, imageData: imageData)
                self.presenter?.presentCouponData(self.couponData!)
                self.presenter?.presentCouponValidation(self.couponData!)
                self.presenter?.presentProgress(isLoading: false)
            }
        }
    }
    
    private func loadViewFromCouponCode(_ couponCode: String) {
        guard let item = try? repository.couponList.fetchCoupon(code: couponCode) else { return }
        couponData = item
        presenter?.presentCouponData(item)
        presenter?.presentCouponValidation(item)
        prepareTextCandidates(from: item.imageData)
    }
    
    private func prepareTextCandidates(from image: Data) {
        presenter?.presentProgress(isLoading: true)
        imageAnalyzer.recognizeText(from: image) { [weak self] texts in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                var recognizedTexts = [String]()
                texts.forEach {
                    if $0.detectedDates.isEmpty {
                        recognizedTexts.append($0)
                    }
                }
                recognizedTexts = recognizedTexts.duplicateRemoved(hasKeyProvider: { $0.hashValue })
                presenter?.presentRecognizedTexts(recognizedTexts)
                presenter?.presentProgress(isLoading: false)
            }
        }
    }
    
    private var canDone: Bool {
        guard let couponData else { return false }
        return !couponData.code.isEmpty
        && !couponData.name.isEmpty
        && !couponData.expired
        && ((mode == .add && !isExistCoupon(code: couponData.code)) || mode == .update && dirty.value)
    }
    
    private func isExistCoupon(code: String) -> Bool {
        (try? repository.couponList.isExistCoupon(code: code)) == true
    }
}
