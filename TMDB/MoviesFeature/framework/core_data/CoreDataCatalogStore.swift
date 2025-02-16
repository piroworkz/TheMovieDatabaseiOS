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
        
    }
    
    public func insert(_ catalog: TMDB.LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion) {
        let context = self.context
        context.perform {
            do {
                ManagedCache.fromLocal(catalog, timestamp, in: context)
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        let context = self.context
        context.perform {
            do {
                let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
                request.returnsObjectsAsFaults = false
                if let cache = try context.fetch(request).first {
                    completion(.found(
                        catalog: cache.local,
                        timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

extension ManagedCache {
    static func fromLocal(_ catalog: TMDB.LocalCatalog, _ timestamp: Date, in context: NSManagedObjectContext) {
        let managedCache = ManagedCache(context: context)
        managedCache.timestamp = timestamp
        managedCache.catalog = ManagedCatalog.fromLocal(catalog, in: context)
    }
}

extension ManagedCatalog {
    static func fromLocal(_ local: LocalCatalog, in context: NSManagedObjectContext) -> ManagedCatalog {
        let managed = ManagedCatalog(context: context)
        managed.page = Int64(local.page)
        managed.totalPages = Int64(local.totalPages)
        
        let managedMovies = local.movies.map { movie -> ManagedMovie in
            let managedMovie = ManagedMovie.fromLocal(movie, in: context)
            managedMovie.catalog = managed // 🔹 Asegurar relación correcta
            return managedMovie
        }
        
        managed.movies = NSOrderedSet(array: managedMovies)
        return managed
    }
}

extension ManagedMovie {
    static func fromLocal(_ local: LocalMovie, in context: NSManagedObjectContext) -> ManagedMovie {
        let managed = ManagedMovie(context: context)
        managed.id = Int64(local.id)
        managed.title = local.title
        managed.posterPath = local.posterPath
        return managed
    }
}


private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loaderError: Swift.Error?
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                loaderError = error
            }
        }
        try loaderError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        return container
    }
}


private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
