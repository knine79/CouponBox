//
//  CouponListRepository.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/11/23.
//

import Foundation
import CoreData

extension CouponRepositoryItem {

    init(coupon: Coupon) {
        self.init(name: coupon.name ?? "",
                  expiresAt: coupon.expiresAt ?? Date(),
                  code: coupon.code ?? "",
                  imageData: coupon.imageData ?? Data())
    }
}

final class CouponListRepository: CouponListRepositoryProtocol {
    private let container: NSPersistentContainer
    init() {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.shouldDeleteInaccessibleFaults = true
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func fetchCouponList() throws -> [CouponRepositoryItem] {
        let request = Coupon.fetchRequest()
        return try context.fetch(request).map { CouponRepositoryItem(coupon: $0) }
    }

    func fetchCoupon(code: String) throws -> CouponRepositoryItem? {
        return try fetchCoupons(code: code).first.map { CouponRepositoryItem(coupon: $0) }
    }
    
    func isExistCoupon(code: String) throws -> Bool {
        try fetchCoupons(code: code).isEmpty == false
    }
    
    func addCoupon(_ coupon: CouponRepositoryItem) throws {
        guard try fetchCoupons(code: coupon.code).isEmpty else { throw RepositoryError.alreadyExistItem }
        guard let entity = NSEntityDescription.entity(forEntityName: "Coupon", in: context) else {
            throw RepositoryError.entityNotFoundError
        }
        let object = NSManagedObject(entity: entity, insertInto: context)
        object.setValue(coupon.name, forKey: "name")
        object.setValue(coupon.code, forKey: "code")
        object.setValue(coupon.expiresAt, forKey: "expiresAt")
        object.setValue(coupon.imageData, forKey: "imageData")
        
        try context.save()
    }
    
    func updateCoupon(_ coupon: CouponRepositoryItem) throws {
        guard let object = try fetchCoupons(code: coupon.code).first else { throw RepositoryError.itemNotFound }
        
        object.setValue(coupon.name, forKey: "name")
        object.setValue(coupon.code, forKey: "code")
        object.setValue(coupon.expiresAt, forKey: "expiresAt")
        object.setValue(coupon.imageData, forKey: "imageData")
        try context.save()
    }
    
    func removeCoupon(code: String) throws {
        try fetchCoupons(code: code)
            .forEach { object in
                context.delete(object)
            }
        
        try context.save()
    }
    
    private func fetchRequest(code: String) -> NSFetchRequest<Coupon> {
        let request = Coupon.fetchRequest()
        request.predicate = NSPredicate(format: "code == %@", code)
        return request
    }
    
    private func fetchCoupons(code: String) throws -> [Coupon] {
        let request = fetchRequest(code: code)
        return try context.fetch(request)
    }
    
    private var context: NSManagedObjectContext {
        container.viewContext
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
