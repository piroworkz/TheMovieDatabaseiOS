//
//  CodableCatalogStorageTests.swift
//  TMDBTests
//
//  Created by David Luna on 12/02/25.
//

import XCTest
import TMDB

class CodableCatalogStorage {
    
    func retrieve(completion: @escaping CatalogStore.RetrieveCompletion) {
        completion(.empty)
    }
}

final class CodableCatalogStorageTests: XCTestCase {
    
    func test_GIVEN_sut_WHEN_retrieveIsCalledAndCacheIsEmpty_THEN_shouldDeliverEmpty() {
        let sut = CodableCatalogStorage()
        let expectation = expectation(description: expectationDescription())
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty catalog but got: \n\(String(describing: result))")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    

}
