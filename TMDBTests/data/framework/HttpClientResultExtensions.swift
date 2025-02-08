//
//  HttpClientResultExtensions.swift
//  TMDBTests
//
//  Created by David Luna on 08/02/25.
//

import XCTest
@testable import TMDB

extension HttpClientResult? {
    
    func isEqual(to expected: HttpClientResult?, file: StaticString = #filePath, line: UInt = #line) {
        switch (self, expected) {
        case let (.success(actualData, actualHTTPURLResponse), .success(expectedData, expectedHTTPURLResponse)):
            XCTAssertEqual(actualData, expectedData, file: file, line: line)
            XCTAssertEqual(actualHTTPURLResponse, expectedHTTPURLResponse, file: file, line: line)
        case let (.failure(actualError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(actualError.domain, expectedError.domain, file: file, line: line)
            XCTAssertEqual(actualError.code, expectedError.code, file: file, line: line)
        default :
            XCTFail("Expected result \(String(describing: expected)) but got \(String(describing: self)) instead", file: file, line: line)
        }
    }
    
    func isNotNil(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(self, file: file, line: line)
    }
}
