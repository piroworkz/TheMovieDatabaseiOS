//
//  CatalogStore.swift
//  TMDB
//
//  Created by David Luna on 10/02/25.
//

import Foundation

protocol CatalogStore {
    typealias StoreCompletion = (Error?) -> Void
    func deleteCachedCatalog(completion: @escaping StoreCompletion)
    func insert(_ catalog: LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion)
}
