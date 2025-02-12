//
//  LoadCatalogFromCacheTests.swift
//  TMDBTests
//
//  Created by David Luna on 11/02/25.
//

import XCTest
import TMDB

final class LoadCatalogFromCacheTests : XCTestCase, XCTStoreTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotLoadCatalogFromCache() {
        let (_, store) = buildSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_GIVEN_sut_WHEN_loadIsCalled_THEN_shouldSendRetrieveMessage() {
        let (sut, store) = buildSut()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    
    func test_GIVEN_sut_WHEN_retrieveFails_THEN_loadShouldReturnError() {
        let (sut, store) = buildSut()
        let expected = anyNSError()
        
        assertThat(
            given: sut,
            whenever: { store.completeRetrieve(with: expected) }
        ).isEqual(to: .failure(expected))
    }
    
    func test_GIVEN_sut_WHEN_cacheIsEmpty_THEN_loadShouldReturnEmptyCatalog() {
        let (sut, store) = buildSut()
        let expected = createCatalog(0)
        
        assertThat(
            given: sut,
            whenever: { store.completeRetrieveSuccessfully() }
        ).isEqual(to: .success(expected))
    }
    
    func test_GIVEN_sut_WHEN_cacheHasNotReachedExpirationDate_THEN_loadShouldReturnCachedCatalog() {
        let now = Date()
        let expirationDate = expirationDate(days: -7, seconds: 1, now)
        let (sut, store) = buildSut(currentDate: { now })
        let expected = createCatalog()
        
        assertThat(
            given: sut,
            whenever: { store.completeRetrieveSuccessfully(with: expected.toLocal(), expirationDate) }
        ).isEqual(to: .success(expected))
    }
    
    func test_GIVEN_sut_WHEN_cacheHasReachedExpirationDate_THEN_loadShouldReturnEmptyCatalog() {
        let now = Date()
        let expirationDate = expirationDate(days: -7, seconds: nil, now)
        let (sut, store) = buildSut(currentDate: { now })
        let expected = createCatalog(0)
        
        assertThat(
            given: sut,
            whenever: { store.completeRetrieveSuccessfully(with: expected.toLocal(), expirationDate) }
        ).isEqual(to: .success(expected))
    }
    
    func test_GIVEN_sut_WHEN_retrieveFailsWithError_THEN_shouldNotHaveSideEffects() {
        let (sut, store) = buildSut()
        
        sut.load { _ in }
        store.completeRetrieve(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    
    func test_GIVEN_sut_WHEN_cacheIsEmpty_THEN_shouldNotHaveSideEffects() {
        let (sut, store) = buildSut()
        
        sut.load { _ in }
        store.completeRetrieveSuccessfully(with: createCatalog(0).toLocal(), Date())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    

    
    func test_GIVEN_sut_WHEN_cacheIsNotExpired_THEN_shouldNotCallDelete() {
        let now = Date()
        let expirationDate = expirationDate(days: -7, seconds: 1, now)
        let (sut, store) = buildSut(currentDate: { now })
        
        sut.load { _ in }
        store.completeRetrieveSuccessfully(with: createCatalog().toLocal(), expirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    func test_GIVEN_sut_WHEN_cacheIsExpired_THEN_shouldCallDelete() {
        let now = Date()
        let expirationDate = expirationDate(days: -7,seconds: -1, now)
        let (sut, store) = buildSut(currentDate: { now })
        
        sut.load { _ in }
        store.completeRetrieveSuccessfully(with: createCatalog(0).toLocal(), expirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve, .deleteCache])
    }
    
    func test_GIVEN_sut_WHEN_sutHasBeenDeallocated_THEN_shouldNotReturnResult() {
        let store = CatalogStoreSpy()
        var sut: LocalCatalogLoader? = LocalCatalogLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalCatalogLoader.LoadResult]()
        sut?.load { receivedResults.append($0) }
        
        sut = nil
        store.completeRetrieveSuccessfully(with: createCatalog(0).toLocal(), Date())
        
        XCTAssertTrue(receivedResults.isEmpty)
    }

}
