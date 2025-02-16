//
//  CoreDataCatalogTests.swift
//  TMDBTests
//
//  Created by David Luna on 15/02/25.
//

import XCTest
import TMDB

final class CoreDataCatalogStoreTests: XCTestCase, CatalogStoreSpecs {
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverEmpty() {
        let sut = buildSut()
        
        assertThatRetrieveResult(sut).isEqual(to: .empty)
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldAlwaysDeliverEmpty() {
        let sut = buildSut()
        
        assertThatRetrieveResult(sut).isEqual(to: .empty)
        assertThatRetrieveResult(sut).isEqual(to: .empty)
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverFoundValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp: Date = Date()
        
        assertThatInsertError(with: (catalog: localCatalog, timestamp: timestamp), sut).isNil()
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverSameFoundValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp: Date = Date()
        
        assertThatInsertError(with: (catalog: localCatalog, timestamp: timestamp), sut).isNil()
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
    }
    
    func test_GIVEN_cacheDataIsNotValid_WHEN_retrieveIsCalled_THEN_shouldDeliverFailureWithError() {
        
    }
    
    func test_GIVEN_cacheDataIsNotValid_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverFailureWithError() {
        
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_insertIsCalled_THEN_shouldOverWriteExistingCache() {
        
    }
    
    func test_GIVEN_invalidStoreURL_WHEN_insertFails_THEN_shouldDeliverInsertError() {
        
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_deleteIsCalled_THEN_shouldNotHaveSideEffects() {
        
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_deleteSucceeds_THEN_shouldDeleteExistingCache() {
        
    }
    
    func test_GIVEN_invalidStoreURL_WHEN_deleteFails_THEN_shouldDeliverDeleteError() {
        
    }
    
    func test_GIVEN_multipleOperations_WHEN_executedSerially_THEN_shouldCompleteOperationsInOrder() {
        
    }
    
}

extension CoreDataCatalogStoreTests {
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> CatalogStore {
        let storeBundle = Bundle(for: CoreDataCatalogStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataCatalogStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(instanceOf: sut)
        return sut
    }
}
