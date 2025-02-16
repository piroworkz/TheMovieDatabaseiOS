//
//  CatalogCacheIntegrationTests.swift
//  TMDBTests
//
//  Created by David Luna on 16/02/25.
//

import XCTest
import TMDB

final class CatalogCacheIntegrationTests: XCTestCase {
    
    
    func test_GIVEN_cacheIsEmpty_WHEN_load_THEN_shouldDeliverEmptyCache() {
        let sut = buildSut()
        let expectation = expectation(description: expectationDescription())
        
        sut.load { result in
            switch result {
            case let .success(catalog):
                XCTAssertEqual(catalog.movies, [])
                XCTAssertEqual(catalog.page, 0)
                XCTAssertEqual(catalog.totalPages, 0)
            case let .failure(error):
                XCTFail("Expected success but got \(error) instead.")
            @unknown default:
                XCTFail("Unknown error occurred.")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    
    
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> GetCatalogCaheUseCase {
        let storeBundle = Bundle(for: CoreDataCatalogStore.self)
        let storeURL = storageURLTests()
        let store = try! CoreDataCatalogStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalCatalogLoader(store: store, currentDate: { Date.init() })
        
        trackMemoryLeaks(instanceOf: store, file: file, line: line)
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        
        return sut
    }
    
    func storageURLTests() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
