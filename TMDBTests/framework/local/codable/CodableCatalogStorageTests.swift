//
//  CodableCatalogStorageTests.swift
//  TMDBTests
//
//  Created by David Luna on 12/02/25.
//

import XCTest
import TMDB

final class CodableCatalogStorageTests: XCTestCase, CatalogStoreSpecs {
    
    override func setUp() {
        super.setUp()
        clearStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        clearStorage()
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverEmpty() {
        let sut = buildSut()
        let expected = CatalogStoreResult.success(.none)
        
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldAlwaysDeliverEmpty() {
        let sut = buildSut()
        let expected = CatalogStoreResult.success(.none)
        
        assertThatRetrieveResult(sut).isEqual(to: expected)
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalled_THEN_shouldDeliverFoundValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp = Date()
        let expected = CatalogStoreResult.success(.some(Cache(localCatalog, timestamp)))
        
        assertThatInsertError(with: (localCatalog, timestamp), sut).isNil()
        
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverSameFoundValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp = Date()
        let expected = CatalogStoreResult.success(.some(Cache(localCatalog, timestamp)))
        
        assertThatInsertError(with: (localCatalog, timestamp), sut).isNil()
        assertThatRetrieveResult(sut).isEqual(to: expected)
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_insertSucceeds_THEN_shouldNotDeliverError() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp: Date = Date()
        
        assertThatInsertError(with: (catalog: localCatalog, timestamp: timestamp), sut).isNil()
    }
    
    func test_GIVEN_cacheDataIsNotValid_WHEN_retrieveIsCalled_THEN_shouldDeliverFailureWithError() {
        let sut = buildSut()
        let expectedError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON."))
        
        try! "invalid data".write(to: storageURLTests(), atomically: false, encoding: .utf8)
        
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
    }
    
    func test_GIVEN_cacheDataIsNotValid_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverFailureWithError() {
        let sut = buildSut()
        let expectedError = DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON."))
        
        try! "invalid data".write(to: storageURLTests(), atomically: false, encoding: .utf8)
        
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
        assertThatRetrieveResult(sut).isEqual(to: .failure(expectedError))
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_insertIsCalled_THEN_shouldOverWriteExistingCache() {
        let sut = buildSut()
        let existingTimestamp = Date()
        let existingLocalCatalog = createCatalog(1).toLocal()
        let newTimeStamp: Date = existingTimestamp.addingTimeInterval(10)
        let newLocalCatalog = createCatalog(2).toLocal()
        let expected = CatalogStoreResult.success(.some(Cache(newLocalCatalog, newTimeStamp)))
        
        assertThatInsertError(with: (catalog: existingLocalCatalog, timestamp: existingTimestamp), sut).isNil()
        
        assertThatInsertError(with: (catalog: newLocalCatalog, timestamp: newTimeStamp), sut).isNil()
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_invalidStoreURL_WHEN_insertFails_THEN_shouldDeliverInsertError() {
        let invalidStoreURL = URL(fileURLWithPath: "invalid://path")
        let sut = buildSut(storeURL: invalidStoreURL)
        let timestamp = Date()
        let localCatalog = createCatalog().toLocal()
        
        assertThatInsertError(with: (catalog: localCatalog, timestamp: timestamp), sut).isNotNil()
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_deleteIsCalled_THEN_shouldNotHaveSideEffects() {
        let sut = buildSut()
        
        assertThatDeleteError(sut).isNil()
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_deleteSucceeds_THEN_shouldDeleteExistingCache() {
        let sut = buildSut()
        let timestamp = Date()
        let localCatalog = createCatalog().toLocal()
        let expected = CatalogStoreResult.success(.none)
        
        assertThatInsertError(with: (catalog: localCatalog, timestamp: timestamp), sut).isNil()
        assertThatDeleteError(sut).isNil()
        
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_invalidStoreURL_WHEN_deleteFails_THEN_shouldDeliverDeleteError() {
        let invalidStoreURL = cachesDirectory()
        let sut = buildSut(storeURL: invalidStoreURL)
        
        assertThatDeleteError(sut).isNotNil()
    }
    
    func test_GIVEN_multipleOperations_WHEN_executedSerially_THEN_shouldCompleteOperationsInOrder() {
        let sut = buildSut()
        var completionOrder = [XCTestExpectation]()
        
        let firstOperation = expectation(description: "first operation")
        sut.insert(createCatalog().toLocal(), Date()) { _ in
            completionOrder.append(firstOperation)
            firstOperation.fulfill()
        }
        
        let secondtOperation = expectation(description: "second operation")
        sut.deleteCachedCatalog { _ in
            completionOrder.append(secondtOperation)
            secondtOperation.fulfill()
        }
        
        let thirdOperation = expectation(description: "third operation")
        sut.insert(createCatalog().toLocal(), Date()) { _ in
            completionOrder.append(thirdOperation)
            thirdOperation.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completionOrder, [firstOperation, secondtOperation, thirdOperation], "Expected side-effects to run serially but operations finished in different order")
    }
}
