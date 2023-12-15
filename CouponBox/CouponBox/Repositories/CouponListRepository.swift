//
//  CouponListRepository.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/11/23.
//

import CouponBox_BusinessRules
import CoreData
import Combine

extension Coupon {

    init(coupon: CouponDAO) {
        self.init(name: coupon.name ?? "",
                  shop: coupon.shop ?? "",
                  expiresAt: coupon.expiresAt ?? .endOfToday,
                  code: coupon.code ?? "",
                  imageData: coupon.imageData ?? Data())
    }
}

final class CouponListRepository: CouponListRepositoryProtocol {
    private let container: NSPersistentContainer
    init(container: NSPersistentContainer) {
        self.container = container
    }

    private var cancellables = Set<AnyCancellable>()
    private var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func fetchCouponList() throws -> [Coupon] {
        try fetchCouponData().map { Coupon(coupon: $0) }
    }
    
    func fetchCoupon(code: String) throws -> Coupon? {
        try fetchCouponData(code: code).first.map { Coupon(coupon: $0) }
    }
    
    func isExistCoupon(code: String) throws -> Bool {
        try fetchCouponData(code: code).isEmpty == false
    }
    
    func addCoupon(_ value: Coupon) throws {
        guard try fetchCouponData(code: value.code).isEmpty else { throw RepositoryError.alreadyExistItem }
        guard let entity = NSEntityDescription.entity(forEntityName: "CouponDAO", in: context) else {
            throw RepositoryError.entityNotFoundError
        }
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(value.name, forKey: "name")
        object.setValue(value.shop, forKey: "shop")
        object.setValue(value.code, forKey: "code")
        object.setValue(value.expiresAt, forKey: "expiresAt")
        object.setValue(value.imageData, forKey: "imageData")
        do {
            try context.save()
        } catch {
            printLog(error)
        }
    }
    
    func updateCoupon(_ value: Coupon) throws {
        guard let object = try fetchCouponData(code: value.code).first else { throw RepositoryError.itemNotFound }
        object.setValue(value.name, forKey: "name")
        object.setValue(value.shop, forKey: "shop")
        object.setValue(value.code, forKey: "code")
        object.setValue(value.expiresAt, forKey: "expiresAt")
        object.setValue(value.imageData, forKey: "imageData")
        do {
            try context.save()
        } catch {
            printLog(error)
        }
    }
    
    func removeCoupon(code: String) throws {
        try fetchCouponData(code: code)
            .forEach { object in
                context.delete(object)
            }
        
        try context.save()
    }
    
    private func fetchCouponData(code: String? = nil) throws -> [CouponDAO] {
        let request = fetchRequest(code: code)
        return try context.fetch(request)
    }
    
    private func fetchRequest(code: String? = nil) -> NSFetchRequest<CouponDAO> {
        let request = CouponDAO.fetchRequest()
        if let code {
            request.predicate = NSPredicate(format: "code == %@", code)
        }
        return request
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
