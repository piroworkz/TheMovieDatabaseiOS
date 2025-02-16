//
//  TMDBCacheIntegrationTests.swift
//  TMDBCacheIntegrationTests
//
//  Created by David Luna on 16/02/25.
//

import XCTest
import TMDB

final class TMDBCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        clearStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        clearStorage()
    }
    
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
    
    func test_GIVEN_multipleInstancesOfSUT_WHEN_loadSucceeds_THEN_shouldDeliverItemsSavedOnDifferentInstance() {
        let sutToPerformSave = buildSut()
        let sutToPerformLoad = buildSut()
        let expected = createCatalog()
        
        let saveExpectation = expectation(description: "Wait for save expectation")
        let loadExpectation = expectation(description: "Wait for load expectation")
        
        sutToPerformSave.save(expected) { result in
            result.isNil()
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 1.0)
        sutToPerformLoad.load { result in
            switch result {
            case let .success(catalog):
                XCTAssertEqual(catalog, expected)
            case let .failure(error):
                XCTFail("Expected success but got \(error) instead.")
            @unknown default:
                XCTFail("Unknown error occurred.")
            }
            loadExpectation.fulfill()
        }
        
        wait(for: [loadExpectation], timeout: 1.0)
    }
    
    
    
    
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> LocalCatalogLoader {
        let storeBundle = Bundle(for: CoreDataCatalogStore.self)
        let storeURL = storageURLTests()
        let store = try! CoreDataCatalogStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalCatalogLoader(store: store, currentDate: { Date.init() })
        
        trackMemoryLeaks(instanceOf: store, file: file, line: line)
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        
        return sut
    }
    
    private func storageURLTests() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func clearStorage() {
        try? FileManager.default.removeItem(at: storageURLTests())
    }
}
