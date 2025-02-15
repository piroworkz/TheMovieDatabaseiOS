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
        
    }
    
    public func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.empty)
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
        container.loadPersistentStores { loaderError = $1 }
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
