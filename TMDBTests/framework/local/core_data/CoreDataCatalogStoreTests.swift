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
    
    func test_GIVEN_cacheIsEmpty_WHEN_insertSucceeds_THEN_shouldNotDeliverError() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp: Date = Date()
        
        assertThatInsertError(with: (catalog: localCatalog, timestamp: timestamp), sut).isNil()
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_insertIsCalled_THEN_shouldOverWriteExistingCache() {
        let sut = buildSut()
        let existingTimestamp = Date()
        let existingLocalCatalog = createCatalog(1).toLocal()
        let newTimeStamp: Date = existingTimestamp.addingTimeInterval(10)
        let newLocalCatalog = createCatalog(2).toLocal()
        
        assertThatInsertError(with: (catalog: existingLocalCatalog, timestamp: existingTimestamp), sut).isNil()
        assertThatInsertError(with: (catalog: newLocalCatalog, timestamp: newTimeStamp), sut).isNil()
        
        assertThatRetrieveResult(sut).isEqual(to: .found(catalog: newLocalCatalog, timestamp: newTimeStamp))
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_deleteIsCalled_THEN_shouldNotHaveSideEffects() {
        let sut = buildSut()
        
        assertThatDeleteError(sut).isNil()
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_deleteSucceeds_THEN_shouldDeleteExistingCache() {
        let sut = buildSut()
        let timestamp = Date()
        let localCatalog = createCatalog().toLocal()
        
        assertThatInsertError(with: (catalog: localCatalog, timestamp: timestamp), sut).isNil()
        assertThatDeleteError(sut).isNil()
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

extension CoreDataCatalogStoreTests {
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> CatalogStore {
        let storeBundle = Bundle(for: CoreDataCatalogStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataCatalogStore(storeURL: storeURL, bundle: storeBundle)
        trackMemoryLeaks(instanceOf: sut)
        return sut
    }
}
