//
//  CodableCatalogStorageTests.swift
//  TMDBTests
//
//  Created by David Luna on 12/02/25.
//

import XCTest
import TMDB

final class CodableCatalogStorageTests: XCTestCase {
    
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
        let timestamp = Date()
        
        assertThatInsertResult(with: (localCatalog, timestamp), sut).isNil()
        
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverSameFoundValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp = Date()
        
        assertThatInsertResult(with: (localCatalog, timestamp), sut).isNil()
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: localCatalog, timestamp: timestamp))
    }
    
    func test_GIVEN_cacheDataIsNotValid_WHEN_retrieveIsCalled_THEN_shouldDeliverFailureWithError() {
        let sut = buildSut()
        let expectedError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON."))
        
        try! "invalid data".write(to: testStorageURL(), atomically: false, encoding: .utf8)
        
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
    }
    
    func test_GIVEN_cacheDataIsNotValid_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverFailureWithError() {
        let sut = buildSut()
        let expectedError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON."))
        
        try! "invalid data".write(to: testStorageURL(), atomically: false, encoding: .utf8)
        
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_insertIsCalled_THEN_shouldOverWriteExistingCache() {
        let sut = buildSut()
        let existingTimestamp = Date()
        let existingLocalCatalog = createCatalog(1).toLocal()
        let newTimeStamp: Date = existingTimestamp.addingTimeInterval(10)
        let newLocalCatalog = createCatalog(2).toLocal()
        
        assertThatInsertResult(with: (catalog: existingLocalCatalog, timestamp: existingTimestamp), sut).isNil()
        
        assertThatInsertResult(with: (catalog: newLocalCatalog, timestamp: newTimeStamp), sut).isNil()
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: newLocalCatalog, timestamp: newTimeStamp))
    }
    
    func test_GIVEN_invalidStoreURL_WHEN_insertFails_THEN_shouldDeliverInsertError() {
        let invalidStoreURL = URL(fileURLWithPath: "invalid://path")
        let sut = buildSut(storeURL: invalidStoreURL)
        let timestamp = Date()
        let localCatalog = createCatalog().toLocal()
        
        assertThatInsertResult(with: (catalog: localCatalog, timestamp: timestamp), sut).isNotNil()
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_deleteIsCalled_THEN_shouldNotHaveSideEffects() {
        let sut = buildSut()
        
        assertThatDeleteResult(sut).isNil()
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_deleteSucceeds_THEN_shouldDeleteExistingCache() {
        let sut = buildSut()
        let timestamp = Date()
        let localCatalog = createCatalog().toLocal()
        
        assertThatInsertResult(with: (catalog: localCatalog, timestamp: timestamp), sut).isNil()
        assertThatDeleteResult(sut).isNil()
        
        assertThatRetrieveResult(sut).isEqual(to: .empty)
    }
    
    func test_GIVEN_invalidStoreURL_WHEN_deleteFails_THEN_shouldDeliverDeleteError() {
        let invalidStoreURL = cachesDirectory()
        let sut = buildSut(storeURL: invalidStoreURL)
        
        assertThatDeleteResult(sut).isNotNil()
    }
}
