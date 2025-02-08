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

    func test_GIVEN_sut_WHEN_getIsCalled_THEN_shouldFailRequestWithError() {
        let url = anyURL()
        let error = anyNSError()
        let sut = buildSut()
        let expectation = expectation(description: expectationDescription())
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        sut.get(from: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failure with error \(error) but got \(result) instead")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

