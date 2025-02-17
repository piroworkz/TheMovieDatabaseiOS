//
//  CatalogStore.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import Foundation

public typealias CatalogStoreResult = Result<Cache?, Error>

public struct Cache {
    public let catalog: LocalCatalog
    public let timestamp: Date
    
    public init(_ catalog: LocalCatalog, _ timestamp: Date) {
        self.catalog = catalog
        self.timestamp = timestamp
    }
}

public protocol CatalogStore {
    typealias StoreCompletion = (Error?) -> Void
    typealias RetrieveCompletion = (CatalogStoreResult) -> Void
    func deleteCachedCatalog(completion: @escaping StoreCompletion)
    func insert(_ catalog: LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion)
    func retrieve(completion: @escaping RetrieveCompletion)
}

extension CatalogStoreResult {
    var foundValues: Cache? {
        if case let .success(.some(cache)) = self {
            return Cache(cache.catalog, cache.timestamp)
        }
        return .none
    }
    
    var error: Error? {
        if case let .failure(error) = self {
            return error
        }
        return nil
    }
    
    var isEmpty: Bool {
        if case .success(.none) = self {
            return true
        }
        return false
    }
}
