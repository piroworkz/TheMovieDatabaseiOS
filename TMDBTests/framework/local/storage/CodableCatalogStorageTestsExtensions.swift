//
//  File.swift
//  TMDB
//
//  Created by David Luna on 14/02/25.
//

import XCTest
import TMDB

extension CodableCatalogStorageTests {
    
    override func setUp() {
        super.setUp()
        clearStorage()
    }
    
    override func tearDown() {
        super.tearDown()
        clearStorage()
    }
    
    func buildSut(storeURL: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> CatalogStore {
        let sut = CodableCatalogStorage(storageURL: storeURL ?? testStorageURL())
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return sut
    }
    
    func testStorageURL() -> URL {
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
    
    func assertThatInsertError(
        with expected: (catalog:LocalCatalog, timestamp: Date),
        _ sut: CatalogStore
    ) -> Error? {
        let expectation = XCTestExpectation(description: "Waiting for retrieve completion")
        
        var receivedError: Error?
        sut.insert(expected.catalog, expected.timestamp) { error in
            receivedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedError
    }
    
    func assertThatDeleteError(
        _ sut: CatalogStore
    ) -> Error? {
        let expectation = XCTestExpectation(description: "Waiting for retrieve completion")
        
        var receivedError: Error?
        sut.deleteCachedCatalog { error in
            receivedError = error
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return receivedError
    }
    
    private func clearStorage() {
        try? FileManager.default.removeItem(at: testStorageURL())
    }
}

extension CatalogStoreResult? {
    
    func isEqual(to expected: CatalogStoreResult?, file: StaticString = #filePath, line: UInt = #line) {
        switch (self, expected) {
        case (.empty, .empty):
            break
            
        case let (.found(actualCatalog, actualTimestamp), .found(expectedCatalog, expectedTimestamp)):
            XCTAssertEqual(actualCatalog, expectedCatalog, file: file, line: line)
            XCTAssertEqual(actualTimestamp, expectedTimestamp, file: file, line: line)
            
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
