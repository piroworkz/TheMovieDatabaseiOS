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
        let timestamp: Date = Date()
        let expected = CatalogStoreResult.success(Cache(localCatalog, timestamp))
        
        assertThatInsertResult(with: (catalog: localCatalog, timestamp: timestamp), sut).isEqual(to: .success(()))
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_retrieveIsCalledMultipleTimes_THEN_shouldDeliverSameFoundValues() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp: Date = Date()
        let expected = CatalogStoreResult.success(Cache(localCatalog, timestamp))
        
        assertThatInsertResult(with: (catalog: localCatalog, timestamp: timestamp), sut).isEqual(to: .success(()))
        assertThatRetrieveResult(sut).isEqual(to: expected)
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_insertSucceeds_THEN_shouldNotDeliverError() {
        let sut = buildSut()
        let localCatalog = createCatalog().toLocal()
        let timestamp: Date = Date()
        
        assertThatInsertResult(with: (catalog: localCatalog, timestamp: timestamp), sut).isEqual(to: .success(()))
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_insertIsCalled_THEN_shouldOverWriteExistingCache() {
        let sut = buildSut()
        let existingTimestamp = Date()
        let existingLocalCatalog = createCatalog(1).toLocal()
        let newTimeStamp: Date = existingTimestamp.addingTimeInterval(10)
        let newLocalCatalog = createCatalog(2).toLocal()
        let expected = CatalogStoreResult.success(Cache(newLocalCatalog, newTimeStamp))
        
        assertThatInsertResult(with: (catalog: existingLocalCatalog, timestamp: existingTimestamp), sut).isEqual(to: .success(()))
        assertThatInsertResult(with: (catalog: newLocalCatalog, timestamp: newTimeStamp), sut).isEqual(to: .success(()))
        
        assertThatRetrieveResult(sut).isEqual(to: expected)
    }
    
    func test_GIVEN_cacheIsEmpty_WHEN_deleteIsCalled_THEN_shouldNotHaveSideEffects() {
        let sut = buildSut()
        
        assertThatDeleteResult(sut).isEqual(to: .success(()))
    }
    
    func test_GIVEN_cacheIsNotEmpty_WHEN_deleteSucceeds_THEN_shouldDeleteExistingCache() {
        let sut = buildSut()
        let timestamp = Date()
        let localCatalog = createCatalog().toLocal()
        
        assertThatInsertResult(with: (catalog: localCatalog, timestamp: timestamp), sut).isEqual(to: .success(()))
        assertThatDeleteResult(sut).isEqual(to: .success(()))
    }
    
    func test_GIVEN_invalidStoreURL_WHEN_deleteFails_THEN_shouldDeliverDeleteError() {
        let invalidStoreURL = cachesDirectory()
        let sut = buildSut(storeURL: invalidStoreURL)
        let expected = Result<Void, Error>.failure(NSError(domain: NSCocoaErrorDomain, code: 513))
        
        assertThatDeleteResult(sut).isEqual(to: expected)
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
