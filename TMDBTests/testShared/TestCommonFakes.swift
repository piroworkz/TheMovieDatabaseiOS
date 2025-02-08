//
//  TestCommonFakes.swift
//  TMDBTests
//
//  Created by David Luna on 08/02/25.
//

import XCTest

extension XCTestCase {
    
    func anyURL() -> URL {
        return URL(string: "https://example.com")!
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "", code: 0, userInfo: nil)
    }
    
    func anyData() -> Data {
        return Data()
    }
    
    func expectationDescription(_ description: String = "Wait for request to complete") -> String {
        return description
    }
    
}
