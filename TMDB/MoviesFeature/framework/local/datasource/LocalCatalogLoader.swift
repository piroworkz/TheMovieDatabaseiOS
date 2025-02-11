//
//  LocalCatalogLoader.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import Foundation

class LocalCatalogLoader {
    
    private let store: CatalogStore
    private let currentDate: () -> Date
    
    init(store: CatalogStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ catalog: Catalog, completion: @escaping (Error?) -> Void) {
        store.deleteCachedCatalog { [unowned self] error in
            if error == nil {
                store.insert(catalog, currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}
