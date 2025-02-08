//
//  TMDBTests.swift
//  TMDBTests
//
//  Created by David Luna on 07/02/25.
//

import XCTest
@testable import TMDB

class RemoteCatalogLoader {
    private let client: HttpClient
    
    init(client: HttpClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "https://api.themoviedb.org/3/movie/popular")!)
    }
}

protocol HttpClient {
    func get(from url: URL)
}

class HttpClientSpy: HttpClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class RemoteCatalogLoaderTests: XCTestCase {
    
    func test_GIVEN_sut_WHEN_initialized_THEN_shouldNotRequestDataFromAPI() {
        let client = HttpClientSpy()
        let _ = RemoteCatalogLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_GIVEN_sutIsInitialized_WHEN_loadIsCalled_THEN_shouldMakeRequestToProvidedUrl() {
        let client = HttpClientSpy()
        let sut = RemoteCatalogLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
}
