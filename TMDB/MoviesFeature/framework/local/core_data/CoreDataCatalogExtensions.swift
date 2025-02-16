//
//  LoadingError.swift
//  TMDB
//
//  Created by David Luna on 15/02/25.
//
import CoreData

internal extension NSPersistentContainer {

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


internal extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
