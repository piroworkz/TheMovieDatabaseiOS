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
        store.deleteCachedCatalog { [unowned self] error in
            if error == nil {
                store.insert(catalog)
            }
        }
    }
}


class CatalogStore {
    typealias Completion = (Error?) -> Void
    var deleteCachedCatalogCount = 0
    var insertCallCount = 0
    private var completions = [Completion]()
    
    func deleteCachedCatalog(completion: @escaping Completion) {
        completions.append(completion)
        deleteCachedCatalogCount += 1
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        completions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        completions[index](nil)
    }
    
    func insert(_ catalog: Catalog) {
        insertCallCount += 1
    }
    
}

final class CacheCatalogUseCaseTest: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_doesNotDeleteCache() {
        let (_, store) = buildSut()
        
        XCTAssertEqual(store.deleteCachedCatalogCount, 0)
    }
    
    func test_GIVEN_sut_WHEN_saveIsCalled_THEN_shouldRequestCacheDeletion() {
        let (sut, store) = buildSut()
        let catalog = createCatalog()
        
        sut.save(catalog)
        
        XCTAssertEqual(store.deleteCachedCatalogCount, 1)
    }
    
    func test_GIVEN_sut_WHEN_deletionFails_THEN_shouldNotRequestCacheInsertion() {
        let (sut, store) = buildSut()
        let catalog = createCatalog()
        
        sut.save(catalog)
        store.completeDeletion(with: anyNSError())
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_GIVEN_sut_WHEN_deletionSucceeds_THEN_shouldRequestCacheInsertion() {
        let (sut, store) = buildSut()
        let catalog = createCatalog()
        
        sut.save(catalog)
        store.completeDeletionSuccessfully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
}

extension CacheCatalogUseCaseTest {
    
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalCatalogLoader, store: CatalogStore) {
        let store = CatalogStore()
        let sut = LocalCatalogLoader(store: store)
        trackMemoryLeaks(instanceOf: store, file: file, line: line)
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return (sut, store)
    }
    
    func createCatalog(_ count: Int = 4) -> Catalog {
        return Catalog(page: 1, totalPages: 0, catalog: (0...count).map { self.createMovie(id: $0) })
    }
    
    
    func createMovie(id: Int) -> Movie {
        return Movie(id: id, title: "Title \(id)", posterPath: "fake poster path \(id)")
    }
}
