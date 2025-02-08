//
//  URLSessionHttpClientTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest
import TMDB

final class URLSessionHttpClientTests: XCTestCase {
    
    func test_GIVEN_sutAndURL_WHEN_getIsCalled_THEN_shouldMakeRequestWithprovidedURL() {
        
        let url = anyURL()
        let sut = buildSut()
        
        let expectation = expectation(description: expectationDescription())
        
        sut.get(from: url) { _ in }
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_GIVEN_sut_WHEN_getIsCalledAndDataTaskReturnsError_THEN_shouldFailRequestWithError() {
        let error = anyNSError()
        assertThatResultCaseFor(data: nil, response: nil, error: error)
            .isEqual(to: .failure(error))
    }
    
    func test_GIVEN_sut_WHEN_getIsCalledAndDataTaskReturnAllNilValues_THEN_shouldFailRequest() {
        assertThatResultCaseFor(data: nil, response: nil, error: nil)
            .isNotNil()
    }
    
    
    func test_GIVEN_sut_WHEN_getIsCalledAndDataTaskReturnAllRepresentationValues_THEN_shouldFailRequest() {
        assertThatResultCaseFor(data: nil, response: nil, error: anyNSError())
            .isNotNil()
        
        assertThatResultCaseFor(data: nil, response: anyUrlResponse(), error: nil)
            .isNotNil()
        
        assertThatResultCaseFor(data: nil, response: anyHttpUrlResponse(), error: nil)
            .isNotNil()
        
        assertThatResultCaseFor(data: anyData(), response: nil, error: nil)
            .isNotNil()
        
        assertThatResultCaseFor(data: anyData(), response: nil, error: anyNSError())
            .isNotNil()
        
        assertThatResultCaseFor(data: nil, response: anyUrlResponse(), error: anyNSError())
            .isNotNil()
        
        assertThatResultCaseFor(data: nil, response: anyHttpUrlResponse(), error: anyNSError())
            .isNotNil()
        
        assertThatResultCaseFor(data: anyData(), response: anyUrlResponse(), error: anyNSError())
            .isNotNil()
        
        assertThatResultCaseFor(data: anyData(), response: anyHttpUrlResponse(), error: anyNSError())
            .isNotNil()
        
        assertThatResultCaseFor(data: anyData(), response: anyUrlResponse(), error: nil)
            .isNotNil()
    }
    
    
}

