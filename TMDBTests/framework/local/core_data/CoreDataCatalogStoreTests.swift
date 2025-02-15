//
//  CoreDataCatalogTests.swift
//  TMDBTests
//
//  Created by David Luna on 15/02/25.
//

import XCTest
import TMDB

class CoreDataCatalogStore: CatalogStore {
    func deleteCachedCatalog(completion: @escaping StoreCompletion) {
        
    }
    
    func insert(_ catalog: TMDB.LocalCatalog, _ timestamp: Date, completion: @escaping StoreCompletion) {
        
    }
    
    func retrieve(completion: @escaping RetrieveCompletion) {
        completion(.empty)
    }
    
    
}

final class CoreDataCatalogStoreTests: XCTestCase, CatalogStoreSpecs {
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverEmpty() {
        let sut = CoreDataCatalogStore()
        
        assertThatRetrieveResult(sut).isEqual(to: .empty)
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldAlwaysDeliverEmpty() {
        
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverFoundValues() {
        
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverSameFoundValues() {
        
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
        let sut = CoreDataCatalogStore()
        trackMemoryLeaks(instanceOf: sut)
        return sut
    }
}
