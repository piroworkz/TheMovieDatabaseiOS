//
//  CatalogStore.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import Foundation

public enum CatalogStoreResult {
    case empty
    case failure(Error)
    case found(catalog: LocalCatalog, timestamp: Date)
}

public protocol CatalogStore {
    typealias StoreCompletion = (Error?) -> Void
    typealias RetrieveCompletion = (CatalogStoreResult) -> Void
    func deleteCachedCatalog(completion: @escaping StoreCompletion)
    func insert(_ catalog: LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion)
    func retrieve(completion: @escaping RetrieveCompletion)
}

extension CatalogStoreResult {
    var foundValues: (catalog: LocalCatalog, timestamp: Date)? {
         if case let .found(catalog, timestamp) = self {
             return (catalog, timestamp)
         }
         return nil
     }
    
    var error: Error? {
        if case let .failure(error) = self {
            return error
        }
        return nil
    }
    
    var isEmpty: Bool {
        if case .empty = self {
            return true
        }
        return false
    }
}
