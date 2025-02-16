//
//  TrackMemoryLeaks.swift
//  TMDB
//
//  Created by David Luna on 07/02/25.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeaks(instanceOf object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Instance should be nil after tear down, Potential memory leak", file: file, line: line)
        }
    }
}
