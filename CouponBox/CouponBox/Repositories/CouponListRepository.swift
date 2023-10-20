//
//  CouponListRepository.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/11/23.
//

import CouponBox_BusinessRules
import CoreData

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

    private var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func fetchCouponList() throws -> [Coupon] {
        let request = CouponDAO.fetchRequest()
        return try context.fetch(request).map { Coupon(coupon: $0) }
    }

    func fetchCoupon(code: String) throws -> Coupon? {
        return try fetchCoupons(code: code).first.map { Coupon(coupon: $0) }
    }
    
    func isExistCoupon(code: String) throws -> Bool {
        try fetchCoupons(code: code).isEmpty == false
    }
    
    func addCoupon(_ coupon: Coupon) throws {
        guard try fetchCoupons(code: coupon.code).isEmpty else { throw RepositoryError.alreadyExistItem }
        guard let entity = NSEntityDescription.entity(forEntityName: "CouponDAO", in: context) else {
            throw RepositoryError.entityNotFoundError
        }
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(coupon.name, forKey: "name")
        object.setValue(coupon.shop, forKey: "shop")
        object.setValue(coupon.code, forKey: "code")
        object.setValue(coupon.expiresAt, forKey: "expiresAt")
        object.setValue(coupon.imageData, forKey: "imageData")
        do {
            try context.save()
        } catch {
            printLog(error)
        }
    }
    
    func updateCoupon(_ coupon: Coupon) throws {
        guard let object = try fetchCoupons(code: coupon.code).first else { throw RepositoryError.itemNotFound }
        object.setValue(coupon.name, forKey: "name")
        object.setValue(coupon.shop, forKey: "shop")
        object.setValue(coupon.code, forKey: "code")
        object.setValue(coupon.expiresAt, forKey: "expiresAt")
        object.setValue(coupon.imageData, forKey: "imageData")
        do {
            try context.save()
        } catch {
            printLog(error)
        }
    }
    
    func removeCoupon(code: String) throws {
        try fetchCoupons(code: code)
            .forEach { object in
                context.delete(object)
            }
        
        try context.save()
    }
    
    private func fetchRequest(code: String) -> NSFetchRequest<CouponDAO> {
        let request = CouponDAO.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", code)
        return request
    }
    
    private func fetchCoupons(code: String) throws -> [CouponDAO] {
        let request = fetchRequest(code: code)
        return try context.fetch(request)
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
