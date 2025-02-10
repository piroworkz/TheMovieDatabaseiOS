//
//  CacheCatalogUseCaseTest.swift
//  TMDBTests
//
//  Created by David Luna on 10/02/25.
//

import XCTest
import TMDB

class LocalCatalogLoader {
    
    private let store: CatalogStore
    
    init(store: CatalogStore) {
        self.store = store
    }
    
    func save(_ catalog: Catalog) {
        store.deleteCachedCatalog()
    }
}


class CatalogStore {
    var deleteCachedCatalogCount = 0
    
    func deleteCachedCatalog() {
        deleteCachedCatalogCount += 1
    }
}

final class CacheCatalogUseCaseTest: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_doesNotDeleteCache() {
        let store = CatalogStore()
        _ = LocalCatalogLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedCatalogCount, 0)
    }
    
    
    func test_GIVEN_sut_WHEN_saveIsCalled_THEN_shouldRequestCacheDeletion() {
        let store = CatalogStore()
        let sut = LocalCatalogLoader(store: store)
        let catalog = createCatalog()
        
        sut.save(catalog)
        
        XCTAssertEqual(store.deleteCachedCatalogCount, 1)
    }
    
}

extension CacheCatalogUseCaseTest {
    
    func createCatalog(_ count: Int = 4) -> Catalog {
        return Catalog(page: 1, totalPages: 0, catalog: (0...count).map { self.createMovie(id: $0) })
    }
    
    
    func createMovie(id: Int) -> Movie {
        return Movie(id: id, title: "Title \(id)", posterPath: "fake poster path \(id)")
    }
}
