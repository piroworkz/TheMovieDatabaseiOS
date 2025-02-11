//
//  Extensions.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import XCTest
import TMDB

extension RemoteCatalogLoader.Result? {
    func isEqual(to expected: RemoteCatalogLoader.Result?, file: StaticString = #filePath, line: UInt = #line) {
        switch (self, expected) {
        case let (.success(actualResult), .success(expectedResult)):
            XCTAssertEqual(actualResult, expectedResult, file: file, line: line)
        case let (.failure(actualResult as RemoteCatalogLoader.Error), .failure(expectedResult as RemoteCatalogLoader.Error)):
            XCTAssertEqual(actualResult, expectedResult, file: file, line: line)
        default :
            XCTFail("Expected result \(String(describing: expected)) but got \(String(describing: self)) instead", file: file, line: line)
        }
    }
}
