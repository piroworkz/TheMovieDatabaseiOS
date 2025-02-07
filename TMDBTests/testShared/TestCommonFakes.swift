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
    
    func anyHttpUrlResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func anyUrlResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func expectationDescription(_ description: String = "Wait for request to complete") -> String {
        return description
    }
    
}
