//
//  LocalCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import Foundation

public final class LocalCatalogLoader: GetCatalogCaheUseCase {
    
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
            case let .success(.some(cache)) where LocalCatalogCachePolicy.validate(cache.timestamp, currentDate: currentDate()):
                completion(.success(cache.catalog.toDomain()))
            case .success:
                completion(.success(Catalog(page: 0, totalPages: 0, movies: [])))
            }
        }
    }
    
}

extension LocalCatalogLoader {
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ catalog: Catalog, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedCatalog { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.insert(catalog: catalog, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func insert(catalog: Catalog, completion: @escaping (SaveResult) -> Void) {
        store.insert(catalog.toLocal(), currentDate()) {[weak self] result in
            guard self != nil else { return }
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
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
            case let .success(.some(cache)) where !LocalCatalogCachePolicy.validate(cache.timestamp, currentDate: currentDate()):
                self.store.deleteCachedCatalog {_ in}
            case .success:
                break
            }
        }
        
    }
    
}
