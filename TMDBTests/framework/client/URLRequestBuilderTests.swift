//
//  URLRequestBuilderTests.swift
//  TMDB
//
//  Created by David Luna on 09/02/25.
//


import XCTest
@testable import TMDB

class URLRequestBuilderTests: XCTestCase {
    
    func test_GIVEN_sutAndEmptyEndpoint_WHEN_buildIsCalled_THEN_shouldReturnNilUrlRequest() {
        let endpoint = ""
        let sut = buildSut()
        
        let actual = sut.build(for: endpoint, method: getMethod())
        
        XCTAssertNil(actual)
    }
    
    func test_GIVEN_sut_WHEN_buildIsSuccessfull_THEN_shouldReturnValidUrlRequest() {
        let endpoint = anyEndpoint()
        let expected = "\(anyBaseUrl())/\(endpoint)?api_key=\(anyApiKey())"
        let sut = buildSut()
        
        let actual = sut.build(for: endpoint, method: getMethod())
        
        XCTAssertNotNil(actual)
        XCTAssertEqual(actual?.httpMethod, getMethod())
        XCTAssertEqual(actual?.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(actual?.url?.absoluteString, expected)
    }
    
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> RequestBuilder {
        let sut = URLRequestBuilder(baseURL: anyBaseUrl(), apiKey: anyApiKey())
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return sut
    }
}
