//
//  ErrorAssertionExtensions.swift
//  TMDB
//
//  Created by David Luna on 16/02/25.
//

import XCTest

extension Error? {
    func isEqual(to expected: NSError?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(self as? NSError, expected, file: file, line: line)
    }
    
    func isNil(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(self, file: file, line: line)
    }
    
    func isNotNil(file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNotNil(self, file: file, line: line)
    }
    
    
}
