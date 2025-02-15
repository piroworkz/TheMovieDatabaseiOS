//
//  CatalogCache.swift
//  TMDB
//
//  Created by David Luna on 14/02/25.
//

import Foundation

internal struct CatalogCache: Codable {
    let catalog: CodableCatalog
    let timestamp: Date
    
    init(catalog: CodableCatalog, timestamp: Date) {
        self.catalog = catalog
        self.timestamp = timestamp
    }
    
    var localCatalog: LocalCatalog {
        return LocalCatalog(page: catalog.page, totalPages: catalog.totalPages, movies: catalog.movies.map { $0.localMovie })
    }
}
