//
//  CatalogResultExtensions.swift
//  TMDB
//
//  Created by David Luna on 16/02/25.
//
import XCTest
import TMDB

extension CatalogResult? {
    
    func isEqual(to expected: CatalogResult?, file: StaticString = #filePath, line: UInt = #line) {
        switch (self, expected) {
        case let (.success(actualCatalog), .success(expectedCatalog)):
            XCTAssertEqual(actualCatalog, expectedCatalog, file: file, line: line)
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
