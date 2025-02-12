//
//  LocalCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import Foundation

public final class LocalCatalogLoader {
    
    private let store: CatalogStore
    private let currentDate: () -> Date
    
    public init(store: CatalogStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalCatalogLoader {
    public typealias LoadResult = CatalogResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(catalog, timestamp) where LocalCatalogCachePolicy.validate(timestamp, currentDate: currentDate()):
                completion(.success(catalog.toDomain()))
            case .found, .empty:
                completion(.success(Catalog(page: 0, totalPages: 0, movies: [])))
            }
        }
    }
    
}

extension LocalCatalogLoader {
    public typealias SaveResult = Error?
    
    public func save(_ catalog: Catalog, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedCatalog { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                completion(error)
            } else {
                self.insert(catalog: catalog, completion: completion)
            }
        }
    }
    
    private func insert(catalog: Catalog, completion: @escaping (SaveResult) -> Void) {
        store.insert(catalog.toLocal(), currentDate()) {[weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalCatalogLoader {
    
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedCatalog {_ in}
            case let .found(_, timestamp) where !LocalCatalogCachePolicy.validate(timestamp, currentDate: currentDate()):
                self.store.deleteCachedCatalog {_ in}
            case .empty, .found:
                break
            }
        }
        
    }
    
}
