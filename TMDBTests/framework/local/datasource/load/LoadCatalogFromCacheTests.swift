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
        let expectation = expectation(description: expectationDescription())
        
        var receivedError: NSError?
        sut.load {error in
            receivedError = error as NSError?
            expectation.fulfill()
        }
        store.completeRetrieve(with: expected)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedError, expected)
    }
    


    
}
