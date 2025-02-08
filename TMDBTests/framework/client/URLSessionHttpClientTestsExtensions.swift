//
//  URLProtocolStub.swift
//  TMDB
//
//  Created by David Luna on 08/02/25.
//

import XCTest
@testable import TMDB

extension URLSessionHttpClientTests {
    
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        
        init(data: Data?, response: URLResponse?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
    }
    
    class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            requestObserver = nil
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response =  URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error =  URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
    
    func buildSut(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHttpClient {
        let urlRequestBuilder = URLRequestBuilder(baseURL: "https://example.com", apiKey: "my fake api key")
        let sut = URLSessionHttpClient(requestBuilder: urlRequestBuilder)
        trackMemoryLeaks(instanceOf: sut, file: file, line: line)
        return sut
    }
    
    func assertThatResultCaseFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HttpClientResult? {
        let sut = buildSut(file: file, line: line)
        let expectation = expectation(description: expectationDescription())
        
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        var result: HttpClientResult?
        sut.get(from: anyEndpoint()) { receivedResult in
            result = receivedResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        return result
    }
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
    }
    
}
