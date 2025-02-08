//
//  TMDBTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest
@testable import TMDB

final class RemoteCatalogLoaderTests: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotRequestDataFromAPI() {
        let (_, spy) = buildSut()
        
        XCTAssertTrue(spy.requestedUrls.isEmpty)
    }
    
    func test_GIVEN_sutIsInitialized_WHEN_loadIsCalled_THEN_shouldMakeRequestToProvidedUrl() {
        let expected = [URL(string: "https://example.com")!]
        let (sut, spy) = buildSut()
        
        sut.load() { _ in }
        
        XCTAssertEqual(spy.requestedUrls, expected)
    }
    
    func test_GIVEN_sutAndExpectedURLsArray_WHEN_loadIsCalledTwice_THEN_shouldMakeRequestToProvidedUrlTwice() {
        let url = URL(string: "https://example.com")!
        let expected = [url, url]
        let (sut, spy) = buildSut()
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(spy.requestedUrls, expected)
    }
    
    func test_GIVEN_sutAndExpectedError_WHEN_loadFails_THEN_shouldReturnError() {
        let expected = NSError(domain: "", code: 0, userInfo: nil)
        let (sut, client) = buildSut()
        
        var actual = [RemoteCatalogLoader.Error]()
        sut.load { actual.append($0) }
        client.complete(with: expected)
        
        XCTAssertEqual(actual, [.connectivity])
    }
    
    func test_GIVEN_sutAndExpectedError_WHEN_loadCompletesWithStatusCodeOtherThan200_THEN_shouldReturnInvalidDataError() {
        let testParams = [199, 201, 400, 404, 500]
        let (sut, client) = buildSut()
        
        testParams.enumerated().forEach {index, expected in
            var actual = [RemoteCatalogLoader.Error]()
            sut.load { actual.append($0) }
            client.complete(withStatusCode: expected, at: index)
            
            XCTAssertEqual(actual, [.invalidData])
        }
    }
}

extension RemoteCatalogLoaderTests {
    
    class HttpClientSpy: HttpClient {
        
        var requestedUrls: [URL] { return messages.map { $0.url } }
        private var messages = [(url: URL, completion: (Error?, HTTPURLResponse?) -> Void)]()
        
        func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(error, nil)
        }
        
        func complete(withStatusCode code: Int, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedUrls[index], statusCode: code, httpVersion: nil, headerFields: nil)
            messages[index].completion(nil, response)
        }
    }
    
    func buildSut(baseURL: URL = URL(string: "https://example.com")!) -> (sut: RemoteCatalogLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteCatalogLoader(baseURL: baseURL, client: client)
        
        return (sut, client)
    }
}
