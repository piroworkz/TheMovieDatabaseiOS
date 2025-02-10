//
//  CacheCatalogUseCaseTest.swift
//  TMDBTests
//
//  Created by David Luna on 10/02/25.
//

import XCTest

class LocalCatalogLoader {
    
    init(store: CatalogStore) {
        self.store = store
    }
}


class CatalogStore {
    var deleteCachedCatalogCount = 0
    
}

final class CacheCatalogUseCaseTest: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_doesNotDeleteCache() {
        let store = CatalogStore()
        _ = LocalCatalogLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedCatalogCount, 0)
    }
}
