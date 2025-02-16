//
//  CoreDataCatalogStore.swift
//  TMDB
//
//  Created by David Luna on 15/02/25.
//

import CoreData

public final class CoreDataCatalogStore: CatalogStore {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CatalogCache", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func deleteCachedCatalog(completion: @escaping StoreCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func insert(_ catalog: TMDB.LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion) {
        perform { context in
            do {
                ManagedCache.make(from: catalog, timestamp, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.found(catalog: cache.local, timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
