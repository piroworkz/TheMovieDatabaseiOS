//
//  LoadCatalogFromCacheTests.swift
//  TMDBTests
//
//  Created by David Luna on 11/02/25.
//

import XCTest
import TMDB

final class LoadCatalogFromCacheTests:XCTestCase, XCTStoreTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotLoadCatalogFromCache() {
        let (_, store) = buildSut()
        
        XCTAssertEqual(store.messages, [])
    }
    
    
    func test_GIVEN_sut_WHEN_loadIsCalled_THEN_shouldSendRetrieveMessage() {
        let (sut, store) = buildSut()
        
        sut.load()
        
        XCTAssertEqual(store.messages, [.retrieve])
    }
    

    
}
