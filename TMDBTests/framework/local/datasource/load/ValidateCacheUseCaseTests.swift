//
//  ValidateCacheUseCaseTests.swift
//  TMDBTests
//
//  Created by David Luna on 12/02/25.
//

import XCTest

final class ValidateCacheUseCaseTests: XCTestCase, XCTStoreTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotLoadCatalogFromCache() {
        let (_, store) = buildSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    func test_GIVEN_sut_WHEN_validateCacheSucceeds_THEN_shouldDeleteCache() {
        let (sut, store) = buildSut()
        
        sut.validateCache()
        store.completeRetrieve(with: anyNSError())
        
        XCTAssertEqual(store.messages, [.retrieve, .deleteCache])
    }
    
    func test_GIVEN_sut_WHEN_validateCacheSucceeds_THEN_shouldNotDeleteOnEmptyCache() {
        let (sut, store) = buildSut()
        
        sut.validateCache()
        store.completeRetrieveSuccessfully(with: createCatalog(0).toLocal(), Date())
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    
    
    func test_GIVEN_sut_WHEN_cacheIsNotExpired_THEN_shouldNotDeleteCache() {
        let now = Date()
        let expirationDate = expirationDate(days: -7, seconds: 1, now)
        let (sut, store) = buildSut(currentDate: { now })
        
        sut.validateCache()
        store.completeRetrieveSuccessfully(with: createCatalog().toLocal(), expirationDate)
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    


}
