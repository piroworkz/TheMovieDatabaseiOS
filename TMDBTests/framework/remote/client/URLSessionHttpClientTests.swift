//
//  URLSessionHttpClientTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest
import TMDB

final class URLSessionHttpClientTests: XCTestCase {
    
    func test_GIVEN_sut_WHEN_getIsCalled_THEN_shouldMakeRequestWithProvidedURL() {
        
        let sut = buildSut()
        
        let expectation = expectation(description: expectationDescription())
        
        sut.get(from: anyEndpoint()) { _ in }
        
        URLProtocolStub.observeRequests { request in
            XCTAssertTrue(((request.url?.absoluteString.contains(anyEndpoint())) != nil))
            XCTAssertEqual(request.httpMethod, "GET")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    
    func test_GIVEN_invalidEndpoint_WHEN_getFails_THEN_shouldReturnError() {
        let invalidEndpoint = "invalid endpoint"
        let sut = buildSut()
        
        sut.get(from: invalidEndpoint) { result in
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
            default:
                return
            }
        }
        
    }
    
    
    
    func test_GIVEN_sut_WHEN_getIsCalledAndDataTaskReturnsError_THEN_shouldFailRequestWithError() {
        let error = anyNSError()
        assertThatResultCaseFor(data: nil, response: nil, error: error).isEqual(to: .failure(error))
    }
    
    func test_GIVEN_sut_WHEN_getIsCalledAndDataTaskReturnAllNilValues_THEN_shouldFailRequest() {
        assertThatResultCaseFor(data: nil, response: nil, error: nil).isNotNil()
    }
    
    
    func test_GIVEN_sut_WHEN_getIsCalledAndDataTaskReturnAllRepresentationValues_THEN_shouldFailRequest() {
        assertThatResultCaseFor(data: nil, response: nil, error: anyNSError()).isNotNil()
        assertThatResultCaseFor(data: nil, response: anyUrlResponse(), error: nil).isNotNil()
        assertThatResultCaseFor(data: anyData(), response: nil, error: nil).isNotNil()
        assertThatResultCaseFor(data: anyData(), response: nil, error: anyNSError()).isNotNil()
        assertThatResultCaseFor(data: nil, response: anyUrlResponse(), error: anyNSError()).isNotNil()
        assertThatResultCaseFor(data: nil, response: anyHttpUrlResponse(), error: anyNSError()).isNotNil()
        assertThatResultCaseFor(data: anyData(), response: anyUrlResponse(), error: anyNSError()).isNotNil()
        assertThatResultCaseFor(data: anyData(), response: anyHttpUrlResponse(), error: anyNSError()).isNotNil()
        assertThatResultCaseFor(data: anyData(), response: anyUrlResponse(), error: nil).isNotNil()
    }
    
    func test_GIVEN_sut_WHEN_getIsCalledAndDataTaskCompletesWithSuccess_THEN_shouldReturnData() {
        assertThatResultCaseFor(data: anyData(), response: anyHttpUrlResponse(), error: nil)
            .isEqual(to: .success((anyData(), anyHttpUrlResponse())))
    }
    
    func test_GIVEN_sut_WHEN_getIsCalledAndDataTaskCompletesWithSuccessAndEmptyData_THEN_shouldReturnEmptyData() {
        let emptyData: Data = Data()
        assertThatResultCaseFor(data: emptyData, response: anyHttpUrlResponse(), error: nil)
            .isEqual(to: .success((emptyData, anyHttpUrlResponse())))
    }
}
