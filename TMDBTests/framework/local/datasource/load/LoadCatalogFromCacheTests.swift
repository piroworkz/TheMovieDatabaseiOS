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
    
}
