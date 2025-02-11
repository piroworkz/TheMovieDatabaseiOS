//
//  LocalCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import Foundation

public final class LocalCatalogLoader {
    public typealias SaveResult = Error?
    private let store: CatalogStore
    private let currentDate: () -> Date
    
    public init(store: CatalogStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func load() {
        store.retrieve()
    }
    
    public func save(_ catalog: Catalog, completion: @escaping (Error?) -> Void) {
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
