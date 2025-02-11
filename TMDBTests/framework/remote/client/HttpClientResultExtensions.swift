//
//  HttpClientResultExtensions.swift
//  TMDBTests
//
//  Created by David Luna on 08/02/25.
//

import XCTest
import TMDB

extension HttpClientResult? {
    
    func isEqual(to expected: HttpClientResult?, file: StaticString = #filePath, line: UInt = #line) {
        switch (self, expected) {
        case let (.success(actualData, actualHTTPURLResponse), .success(expectedData, expectedHTTPURLResponse)):
            XCTAssertEqual(actualData, expectedData, file: file, line: line)
            XCTAssertEqual(actualHTTPURLResponse.statusCode, expectedHTTPURLResponse.statusCode, file: file, line: line)
            XCTAssertEqual(actualHTTPURLResponse.url, expectedHTTPURLResponse.url, file: file, line: line)
            
        case let (.failure(actualError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(actualError.domain, expectedError.domain, file: file, line: line)
            XCTAssertEqual(actualError.code, expectedError.code, file: file, line: line)
        default :
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
