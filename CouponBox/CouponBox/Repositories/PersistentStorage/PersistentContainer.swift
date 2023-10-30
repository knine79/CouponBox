//
//  PersistentContainer.swift
//  CouponBox
//
//  Created by Samuel Kim on 10/20/23.
//

import CoreData

struct PersistentContainer {
    static let `default`: NSPersistentContainer = {
        container(for: URL.storeURL(for: "group.com.samuel.CouponBox", databaseName: "CouponBox"))
    }()
    
    static let `fake`: NSPersistentContainer = {
        container(for: URL(fileURLWithPath: "/dev/null"))
    }()
    
    private init() {}
    
    private static func container(for url: URL?) -> NSPersistentContainer {
        let container = NSPersistentCloudKitContainer(name: "CouponBox")
        if let url {
            let storeDescription = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [storeDescription]
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
}

private extension URL {
    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL? {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            return nil
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
