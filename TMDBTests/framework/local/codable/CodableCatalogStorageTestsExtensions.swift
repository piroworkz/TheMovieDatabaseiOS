//
//  File.swift
//  TMDB
//
//  Created by David Luna on 14/02/25.
//

import XCTest
import TMDB

extension CatalogStoreSpecs where Self: XCTestCase {
    
    func buildSut(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CatalogStore {
        let sut = CodableCatalogStorage(storageURL: storeURL ?? storageURLTests())
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return sut
    }
    
    func storageURLTests() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func assertThatRetrieveResult(
        _ sut: CatalogStore
    ) -> CatalogStoreResult? {
        let expectation = XCTestExpectation(description: "Waiting for retrieve completion")
        
        var receivedResult: CatalogStoreResult?
        sut.retrieve { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedResult
    }
    
    func assertThatInsertResult(
        with expected: (catalog:LocalCatalog, timestamp: Date),
        _ sut: CatalogStore
    ) -> CatalogStore.StoreResult? {
        let expectation = XCTestExpectation(description: "Waiting for retrieve completion")
        
        var receivedResult:  CatalogStore.StoreResult?
        sut.insert(expected.catalog, expected.timestamp) { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedResult
    }
    
    func assertThatDeleteResult(
        _ sut: CatalogStore
    ) -> CatalogStore.StoreResult? {
        let expectation = XCTestExpectation(description: "Waiting for retrieve completion")
        
        var receivedResult:  CatalogStore.StoreResult?
        sut.deleteCachedCatalog { result in
            receivedResult = result
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedResult
    }
    
    func clearStorage() {
        try? FileManager.default.removeItem(at: storageURLTests())
    }
}

extension CatalogStoreResult? {
    
    func isEqual(to expected: CatalogStoreResult?, file: StaticString = #filePath, line: UInt = #line) {
        switch (self, expected) {
        case (.success(.none), .success(.none)):
            break
            
        case let (.success(.some(actual)), .success(.some(cache))):
            XCTAssertEqual(actual.catalog, cache.catalog, file: file, line: line)
            XCTAssertEqual(actual.timestamp, cache.timestamp, file: file, line: line)
            
        case let (.failure(actualError), .failure(expectedError)):
            if let actualNSError = actualError as NSError?, let expectedNSError = expectedError as NSError? {
                XCTAssertEqual(actualNSError.domain, expectedNSError.domain, file: file, line: line)
                XCTAssertEqual(actualNSError.code, expectedNSError.code, file: file, line: line)
            } else if let actualDecodingError = actualError as? DecodingError, let expectedDecodingError = expectedError as? DecodingError {
                XCTAssertEqual(actualDecodingError.localizedDescription, expectedDecodingError.localizedDescription, file: file, line: line)
            } else {
                XCTFail("Errors are of different types or are not comparable", file: file, line: line)
            }
            
        default:
            XCTFail("Expected result \(String(describing: expected)) but got \(String(describing: self)) instead", file: file, line: line)
        }
    }
    
    func isNotNil(file: StaticString = #filePath, line: UInt = #line) {
        if case .failure(let error) = self {
            XCTAssertNotNil(error, file: file, line: line)
        } else {
            XCTFail("Expected failure but got \(String(describing: self))", file: file, line: line)
        }
    }
}
