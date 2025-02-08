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
        
        sut.load()
        
        XCTAssertEqual(spy.requestedUrls, expected)
    }
    
    func test_GIVEN_sutAndExpectedURLsArray_WHEN_loadIsCalledTwice_THEN_shouldMakeRequestToProvidedUrlTwice() {
        let url = URL(string: "https://example.com")!
        let expected = [url, url]
        let (sut, spy) = buildSut()
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(spy.requestedUrls, expected)
    }
    
    func test_GIVEN_sutAndExpectedError_WHEN_loadFails_THEN_shouldReturnError() {
        let expected = NSError(domain: "", code: 0, userInfo: nil)
        let (sut, client) = buildSut()
        
        client.error = expected
        var capturedError: RemoteCatalogLoader.Error?
        sut.load { error in
            capturedError = error
        }
        
        XCTAssertEqual(capturedError, .connectivity)
    }
}

extension RemoteCatalogLoaderTests {
    
    class HttpClientSpy: HttpClient {
        var requestedUrls: [URL] = []
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedUrls.append(url)
        }
    }
    
    func buildSut(baseURL: URL = URL(string: "https://example.com")!) -> (sut: RemoteCatalogLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteCatalogLoader(baseURL: baseURL, client: client)
        
        return (sut, client)
    }
}
