//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Samuel Kim on 10/26/23.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers
import CouponBox_BusinessRules

class ShareNavigationController: UIViewController {

    private var useCase: CouponEditingUseCase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemGray6
        
        guard let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] else {
                return
            }

            for extensionItem in extensionItems {
                if let itemProviders = extensionItem.attachments {
                    for itemProvider in itemProviders {
                        if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {

                            _ = itemProvider.loadDataRepresentation(for: UTType.image) { data, error in
                                if let data {
                                    DispatchQueue.main.async { [weak self] in
                                        guard let self else { return }
                                        
                                        let presenter = CouponEditingViewPresenter()
                                        useCase = UseCaseFactory.create()
                                            .createCouponEditingUseCase(presenter: presenter, couponImageData: data) { [weak self] _ in
                                                self?.completeShareExtension()
                                            }
                                        let controller = CouponEditingViewController(couponEditingUseCase: useCase)
                                        let editingView = CouponEditingView(viewModel: presenter.viewModel, controller: controller)
                                        
                                        let hostingController = UIHostingController(rootView: editingView)
                                        addChild(hostingController)
                                        view.addSubview(hostingController.view)
                                        hostingController.view.frame = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.width, height: view.frame.height - 48))
                                        hostingController.didMove(toParent: self)
                                    }
                                    return
                                }
                            }
                        }
                    }
                }
            }
        
        NotificationCenter.default.addObserver(forName: .NSExtensionHostDidEnterBackground, object: nil, queue: nil) { [weak self] _ in
            self?.completeShareExtension()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        completeShareExtension()
        super.viewDidDisappear(animated)
    }
    
    func completeShareExtension(completion: ((Bool) -> Void)? = nil) {
        extensionContext?.completeRequest(returningItems: nil)
    }
}
