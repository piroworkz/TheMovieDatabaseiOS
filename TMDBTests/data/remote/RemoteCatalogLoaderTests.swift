//
//  TMDBTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest
@testable import TMDB

class RemoteCatalogLoader {
    private let baseURL: URL
    private let client: HttpClient
    
    init(baseURL: URL, client: HttpClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    func load() {
        client.get(from: baseURL)
    }
}

protocol HttpClient {
    func get(from url: URL)
}

final class RemoteCatalogLoaderTests: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotRequestDataFromAPI() {
        let (_, client) = buildSut()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_GIVEN_sutIsInitialized_WHEN_loadIsCalled_THEN_shouldMakeRequestToProvidedUrl() {
        let (sut, client) = buildSut()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}

extension RemoteCatalogLoaderTests {
    
    class HttpClientSpy: HttpClient {
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }
    }
    
    func buildSut(baseURL: URL = URL(string: "https://example.com")!) -> (sut: RemoteCatalogLoader, client: HttpClientSpy) {
        let client = HttpClientSpy()
        let sut = RemoteCatalogLoader(baseURL: baseURL, client: client)
        
        return (sut, client)
    }
}
