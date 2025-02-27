//
//  ManagedCache.swift
//  TMDB
//
//  Created by David Luna on 15/02/25.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var catalog: ManagedCatalog
    
    var local: LocalCatalog {
        return catalog.asLocal
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: String(describing: ManagedCache.self))
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func make(from catalog: TMDB.LocalCatalog, _ timestamp: Date, in context: NSManagedObjectContext) {
        if let existingCache = try? find(in: context) {
            context.delete(existingCache)
        }
        let managedCache = ManagedCache(context: context)
        managedCache.timestamp = timestamp
        managedCache.catalog = ManagedCatalog.toManagedCatalog(catalog, in: context)
    }
}
